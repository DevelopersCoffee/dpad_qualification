# dpad_qualification — backlog

Prioritized from the 2026-09-15 v1.1 roadmap snapshot and the 2026-10-15 repo audit. Status: **Done**, **Pending**, **Blocked**, **Deferred**, **Needs verification**.

## P0 — repo health

| ID | Item | Status | Notes |
| --- | --- | --- | --- |
| H-1 | CI green on `main` | **Blocked** | Fails at `dart pub publish --dry-run` when `analysis_options.yaml` is mutated during `flutter pub get` ([run 34933283139](https://github.com/DevelopersCoffee/dpad_qualification/actions/runs/34933283139)) |
| H-2 | Publish workflow Flutter SDK matches `environment: sdk: ^3.12.0` | **Needs verification** | `.github/workflows/publish.yml` pins `3.29.3`; local check of that tag yielded Dart 3.7.2 (incompatible with current pubspec). Confirm pin or bump before next tag |
| H-3 | Commit or revert Flutter-generated `analysis_options.yaml` exclude | **Pending** | Stabilizes dry-run; document in release checklist |

## P1 — roadmap test gaps (Track B)

| ID | Item | Status | Suggested test location |
| --- | --- | --- | --- |
| T-1 | Overlay bezel toggle | **Pending** | `test/device_qualification_overlay_test.dart` |
| T-2 | Dispatch tests for all remote keys (arrows, select, back, play/pause, menu) | **Pending** | `test/dpad_remote_controller_test.dart` |
| T-3 | `autoCycle` advances viewport on timer | **Pending** | `test/device_qualification_overlay_test.dart` + `fakeAsync` |
| T-4 | `DeviceQualificationPhaseStatus.parse` edge cases | **Pending** | `test/device_qualification_report_test.dart` |
| T-5 | `toPublicMap()` shape / blocking findings aggregation | **Pending** | `test/device_qualification_report_test.dart` |
| T-6 | Defect draft persistence round-trip | **Needs verification** | Overlay test with `SharedPreferences` mock |
| T-7 | `MediaQuery.navigationMode` for TV presets | **Needs verification** | `test/resolution_simulator_test.dart` (roadmap marked partial) |
| T-8 | Optional golden: simulator bezel | **Deferred** | `test/resolution_simulator_test.dart` |

## P2 — docs & DX (Track A / design review)

| ID | Item | Status |
| --- | --- | --- |
| D-1 | Document `autoCycle` in README | **Pending** |
| D-2 | Document `HardwareKeyboard` / desktop-web-first limits + Android TV physical remote | **Pending** |
| D-3 | Dartdoc on public API surface | **Pending** |
| D-4 | Example app screenshots in `example/README.md` | **Pending** |
| D-5 | Snackbar when clipboard export fails | **Pending** |
| D-6 | Empty defect list / error states in overlay | **Pending** |
| D-7 | Semantics for overlay chrome (not only remote) | **Pending** |

## P3 — integration & downstream

| ID | Item | Status |
| --- | --- | --- |
| I-1 | Run example `integration_test` on CI (emulator or linux/web target) | **Pending** |
| I-2 | Fire TV / Android TV hardware qualification for apps using this harness (e.g. Aika Stream TV) | **Needs verification** |
| I-3 | GitHub Release notes for `v1.1.0` | **Pending** (tag exists; release listing shows only `v1.0.0`) |

## Deferred (roadmap OUT scope)

| Item | Status |
| --- | --- |
| Real OS network throttling without host cooperation | **Deferred** |
| First-party Apple TV / Roku presets | **Deferred** |
| GitHub API issue creation (OAuth) | **Deferred** |
| Extract overlay to separate package | **Deferred** |
| CI matrix runner product | **Deferred** |
