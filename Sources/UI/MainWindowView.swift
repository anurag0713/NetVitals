import SwiftUI
import Charts

public struct MainWindowView: View {
    @ObservedObject var monitor: NetworkMonitor

    public init(monitor: NetworkMonitor) {
        self.monitor = monitor
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Header Bar
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NetVitals Monitor")
                        .font(.title2.bold())
                    Text("Real-time network telemetry & bandwidth monitor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Active Interface")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(monitor.activeInterface)
                            .font(.caption.bold())
                    }
                }
            }
            .padding(.top, 10)

            // Speed Cards
            HStack(spacing: 16) {
                MetricCard(
                    title: "Incoming Traffic (Download)",
                    value: monitor.currentSnapshot.downloadFormatted,
                    subtitle: "Cumulative: \(NetworkTrafficSnapshot.formatBytes(monitor.currentSnapshot.totalDownloadBytes))",
                    icon: "arrow.down.circle.fill",
                    color: .green
                )

                MetricCard(
                    title: "Outgoing Traffic (Upload)",
                    value: monitor.currentSnapshot.uploadFormatted,
                    subtitle: "Cumulative: \(NetworkTrafficSnapshot.formatBytes(monitor.currentSnapshot.totalUploadBytes))",
                    icon: "arrow.up.circle.fill",
                    color: .blue
                )
            }

            // Live Activity Chart
            VStack(alignment: .leading, spacing: 8) {
                Text("Traffic Flow (Last 60 Seconds)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                if #available(macOS 13.0, *) {
                    Chart {
                        ForEach(Array(monitor.history.enumerated()), id: \.offset) { index, snapshot in
                            LineMark(
                                x: .value("Time", index),
                                y: .value("Download (KB/s)", snapshot.downloadBytesPerSec / 1024),
                                series: .value("Type", "Download")
                            )
                            .foregroundStyle(.green)
                            .interpolationMethod(.monotone)

                            LineMark(
                                x: .value("Time", index),
                                y: .value("Upload (KB/s)", snapshot.uploadBytesPerSec / 1024),
                                series: .value("Type", "Upload")
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .frame(height: 220)
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .cornerRadius(10)
                } else {
                    Text("Charts require macOS 13+")
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 650, minHeight: 480)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
