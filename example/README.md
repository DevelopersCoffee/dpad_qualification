# D-Pad Qualification Example App

This example demonstrates `DeviceQualificationOverlay`, simulated TV viewports, on-screen D-Pad remote emulation, telemetry, and defect export.

## Running locally

```bash
cd example
flutter pub get
flutter run -d chrome   # or macos, linux, android
```

On **Linux CI**, integration tests run headless:

```bash
flutter test integration_test/qualification_test.dart -d linux
```

## What to verify manually

1. Tap **QA OVERLAY** (bottom-left) and open **Device Qualification Menu**.
2. Switch to **Android TV 1080p** and toggle **Show Screen Bezel**.
3. Enable **Show Remote Controller Overlay** and use the on-screen D-Pad.
4. Fill the defect form and use **Export Report to Clipboard**.

## Screenshots (capture locally)

After `flutter run -d macos` or `-d linux`, capture:

| File (suggested) | Contents |
| --- | --- |
| `example/screenshots/overlay-panel.png` | QA panel open with device picker |
| `example/screenshots/tv-viewport.png` | 1080p TV viewport with bezel |
| `example/screenshots/dpad-remote.png` | On-screen remote over the demo app |

Commit screenshots under `example/screenshots/` when refreshing store or docs assets.
