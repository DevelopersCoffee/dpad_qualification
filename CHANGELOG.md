## 1.1.0

* Added `enabled` toggle (defaults to `kDebugMode`) and optimized FPS telemetry via frame timings.
* Added `SimulatedViewport`, `CustomSimulatedDevice`, and `ResolutionSimulator.viewport` for custom device presets.
* Added `writeQualificationReportFiles()` for JSON + Markdown report export to disk.
* Added `NetworkQualificationHook` so host apps can react to network context label changes.
* Added GitHub issue URL builder and overlay button to copy prefilled issue links.
* Added screenshot capture to overlay when `screenshotDirectory` is set (desktop/mobile).
* Persist defect form drafts alongside device, bezel, and network settings.
* Expanded overlay and report export test coverage; added example integration test.
* CI now analyzes the example app.

## 1.0.1

* Fixed Home button on `DpadRemoteController` (missing physical key mapping).
* Fixed `onFormFactorOverride` reporting `native` instead of `tablet` for the native device preset.
* Persist overlay device, bezel, and network context label via `shared_preferences`.
* Renamed network UI to honest "Network Context Label" (metadata for reports, not traffic throttling).
* Expanded README: full device table, report builder example, and documented optional overlay APIs.
* Added accessibility semantics labels on remote control buttons.

## 1.0.0

* Initial release of `dpad_qualification`.
* Added `ResolutionSimulator` supporting TV (720p, 1080p, 4K), Tablet, Mobile, and Foldable viewports.
* Added `DpadRemoteController` for interactive on-screen TV remote control emulation with native keyboard events.
* Added `DeviceQualificationOverlay` for interactive device testing, FPS telemetry tracking, and defect report generation.
* Added `DeviceQualificationReportBuilder` for automated headless phase evidence reporting.
