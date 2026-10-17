import SwiftUI

@main
struct NetVitalsApp: App {
    @StateObject private var monitor = NetworkMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuBarPopoverView(monitor: monitor)
        } label: {
            MenuBarLabelView(monitor: monitor)
        }
        .menuBarExtraStyle(.window)

        Window("NetVitals Monitor", id: "main-window") {
            MainWindowView(monitor: monitor)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 700, height: 500)
    }
}
