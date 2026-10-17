import Foundation
import Combine
import SystemConfiguration

public struct NetworkTrafficSnapshot {
    public let uploadBytesPerSec: Double
    public let downloadBytesPerSec: Double
    public let totalUploadBytes: UInt64
    public let totalDownloadBytes: UInt64
    public let timestamp: Date

    public var uploadFormatted: String {
        NetworkTrafficSnapshot.formatSpeed(uploadBytesPerSec)
    }

    public var downloadFormatted: String {
        NetworkTrafficSnapshot.formatSpeed(downloadBytesPerSec)
    }

    public static func formatSpeed(_ bytesPerSec: Double) -> String {
        if bytesPerSec < 1024 {
            return String(format: "%.0f B/s", bytesPerSec)
        } else if bytesPerSec < 1024 * 1024 {
            return String(format: "%.1f KB/s", bytesPerSec / 1024)
        } else if bytesPerSec < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB/s", bytesPerSec / (1024 * 1024))
        } else {
            return String(format: "%.2f GB/s", bytesPerSec / (1024 * 1024 * 1024))
        }
    }

    public static func formatBytes(_ bytes: UInt64) -> String {
        let b = Double(bytes)
        if b < 1024 {
            return String(format: "%.0f B", b)
        } else if b < 1024 * 1024 {
            return String(format: "%.1f KB", b / 1024)
        } else if b < 1024 * 1024 * 1024 {
            return String(format: "%.1f MB", b / (1024 * 1024))
        } else {
            return String(format: "%.2f GB", b / (1024 * 1024 * 1024))
        }
    }
}

public class NetworkMonitor: ObservableObject {
    @Published public var currentSnapshot: NetworkTrafficSnapshot = NetworkTrafficSnapshot(
        uploadBytesPerSec: 0,
        downloadBytesPerSec: 0,
        totalUploadBytes: 0,
        totalDownloadBytes: 0,
        timestamp: Date()
    )

    @Published public var history: [NetworkTrafficSnapshot] = []
    @Published public var activeInterface: String = "en0"

    private var previousUploadBytes: UInt64 = 0
    private var previousDownloadBytes: UInt64 = 0
    private var previousTimestamp: Date = Date()
    private var timer: AnyCancellable?

    public init() {
        startMonitoring()
    }

    public func startMonitoring() {
        let (initialIn, initialOut) = fetchSystemByteCounters()
        self.previousDownloadBytes = initialIn
        self.previousUploadBytes = initialOut
        self.previousTimestamp = Date()

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sample()
            }
    }

    public func stopMonitoring() {
        timer?.cancel()
        timer = nil
    }

    private func sample() {
        let now = Date()
        let timeInterval = now.timeIntervalSince(previousTimestamp)
        guard timeInterval > 0 else { return }

        let (totalIn, totalOut) = fetchSystemByteCounters()

        var deltaIn: Double = 0
        var deltaOut: Double = 0

        if previousDownloadBytes > 0 && totalIn >= previousDownloadBytes {
            deltaIn = Double(totalIn - previousDownloadBytes) / timeInterval
        }
        if previousUploadBytes > 0 && totalOut >= previousUploadBytes {
            deltaOut = Double(totalOut - previousUploadBytes) / timeInterval
        }

        previousDownloadBytes = totalIn
        previousUploadBytes = totalOut
        previousTimestamp = now

        let snapshot = NetworkTrafficSnapshot(
            uploadBytesPerSec: deltaOut,
            downloadBytesPerSec: deltaIn,
            totalUploadBytes: totalOut,
            totalDownloadBytes: totalIn,
            timestamp: now
        )

        self.currentSnapshot = snapshot
        self.history.append(snapshot)
        if self.history.count > 60 {
            self.history.removeFirst()
        }
    }

    private func fetchSystemByteCounters() -> (inBytes: UInt64, outBytes: UInt64) {
        var ifap: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifap) == 0, let firstAddr = ifap else {
            return (0, 0)
        }
        defer { freeifaddrs(ifap) }

        var totalIn: UInt64 = 0
        var totalOut: UInt64 = 0

        var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while let current = cursor {
            let flags = Int32(current.pointee.ifa_flags)
            let isUp = (flags & IFF_UP) == IFF_UP
            let isRunning = (flags & IFF_RUNNING) == IFF_RUNNING
            let isLoopback = (flags & IFF_LOOPBACK) == IFF_LOOPBACK

            if isUp && isRunning && !isLoopback {
                let name = String(cString: current.pointee.ifa_name)
                // Filter out non-primary pseudo interfaces if desired, or aggregate active interfaces (en0, en1, etc.)
                if name.hasPrefix("en") || name.hasPrefix("utun") || name.hasPrefix("pdp_ip") {
                    if let data = current.pointee.ifa_data {
                        let networkData = data.assumingMemoryBound(to: if_data.self)
                        totalIn += UInt64(networkData.pointee.ifi_ibytes)
                        totalOut += UInt64(networkData.pointee.ifi_obytes)
                    }
                }
            }
            cursor = current.pointee.ifa_next
        }

        return (totalIn, totalOut)
    }
}
