import SwiftUI

public struct MenuBarPopoverView: View {
    @ObservedObject var monitor: NetworkMonitor
    @Environment(\.openWindow) private var openWindow

    public init(monitor: NetworkMonitor) {
        self.monitor = monitor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Label("NetVitals", systemImage: "waveform.path.ecg")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    openWindow(id: "main-window")
                    NSApplication.shared.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "macwindow")
                }
                .buttonStyle(.plain)
                .help("Open Full Network Monitor")
            }

            Divider()

            // Current Speeds
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Upload")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(monitor.currentSnapshot.uploadFormatted)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.green)
                        Text("Download")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(monitor.currentSnapshot.downloadFormatted)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
            .padding(.horizontal, 4)

            Divider()

            // Session Total
            VStack(alignment: .leading, spacing: 6) {
                Text("CUMULATIVE SESSION USAGE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                HStack {
                    Text("Sent:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(NetworkTrafficSnapshot.formatBytes(monitor.currentSnapshot.totalUploadBytes))
                        .font(.caption.monospacedDigit())
                }

                HStack {
                    Text("Received:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(NetworkTrafficSnapshot.formatBytes(monitor.currentSnapshot.totalDownloadBytes))
                        .font(.caption.monospacedDigit())
                }
            }

            Divider()

            // Footer / Actions
            HStack {
                Button("Flush DNS") {
                    let task = Process()
                    task.launchPath = "/usr/bin/dscacheutil"
                    task.arguments = ["-flushcache"]
                    try? task.run()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(14)
        .frame(width: 260)
    }
}
