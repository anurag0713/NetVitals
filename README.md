# NetVitals

A lightweight, real-time macOS network telemetry and bandwidth monitoring utility for the menu bar and desktop widgets.

## Features

- **Menu Bar Traffic Rates**: Real-time upload and download speeds (`▲ KB/s  ▼ KB/s`) right in your menu bar.
- **Quick-Glance HUD**: Instant access to upload/download rates, cumulative session data usage, and network actions (like flushing DNS cache).
- **Traffic Dashboard**: SwiftUI chart showing live traffic history over the last 60 seconds.
- **Pure Native Swift & SwiftUI**: 100% free system APIs (`getifaddrs`, `Charts`, `AppKit`, `SwiftUI`) with zero paid developer account or kernel extensions required.

## Building & Running

### Requirements
- macOS 14.0 or higher
- Xcode 15.0 or higher
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (optional, if modifying `project.yml`)

### Build via Xcode
Open `NetVitals.xcodeproj` in Xcode and hit **Run** (⌘R).

### Build via Terminal
```bash
xcodebuild -project NetVitals.xcodeproj -scheme NetVitals -destination "platform=macOS" build
```

## License
MIT (See [LICENSE](LICENSE))
