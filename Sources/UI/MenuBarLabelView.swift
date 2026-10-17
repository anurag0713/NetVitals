import SwiftUI

public struct MenuBarLabelView: View {
    @ObservedObject var monitor: NetworkMonitor

    public init(monitor: NetworkMonitor) {
        self.monitor = monitor
    }

    public var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "waveform.path.ecg")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)

            HStack(spacing: 3) {
                Text("▲")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(monitor.currentSnapshot.uploadFormatted)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))

                Text("▼")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.secondary)
                Text(monitor.currentSnapshot.downloadFormatted)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
        }
    }
}
