# dpad_qualification — project status

**Last updated:** 2026-10-15 (Cloud Agent audit)  
**Roadmap source:** `dpad_qualification v1.1 Roadmap Plan` (2026-09-15 snapshot; historical, not live planning authority)

## Baseline

| Item | Value | Evidence |
| --- | --- | --- |
| Git `main` HEAD | `07e5770618d669c4d285e0b29b7ca77b80991304` | `git rev-parse HEAD` |
| Package version (`pubspec.yaml`) | `1.1.0` | `pubspec.yaml` |
| Git tags | `v1.0.0`, `v1.1.0` (`v1.1.0` → `51dd887`) | `git tag -l` |
| GitHub releases | `v1.0.0` only (no GitHub Release asset for `v1.1.0`) | `gh release list` |
| pub.dev | Latest **`1.1.0`** (published 2026-09-15); versions **`1.0.0`**, **`1.1.0`** only | `https://pub.dev/api/packages/dpad_qualification` |
| Merged release PR | [#1 Release v1.1.0](https://github.com/DevelopersCoffee/dpad_qualification/pull/1) → `51dd887` | GitHub |
| Post-release commit on `main` | `07e5770` — publish workflow Flutter pin | Not in `v1.1.0` tag |
| Downstream context (Airo / Aika Stream TV) | Fire TV / D-Pad qualification called out in product notes; no in-repo dependency on this package | Historical Airo planning notes (harness usage is conceptual) |

## Stabilization (VM, 2026-10-15)

Flutter **3.47.7** / Dart **3.13.5** (satisfies `environment: sdk: ^3.12.0`).

| Check | Command | Result |
| --- | --- | --- |
| Format | `dart format --output=none --set-exit-if-changed .` | **Done** (exit 0) |
| Analyze (package) | `flutter analyze --fatal-infos` | **Done** |
| Analyze (example) | `cd example && flutter analyze --fatal-infos` | **Done** |
| Unit / widget tests | `flutter test --coverage` | **Done** (15 tests, exit 0) |
| Publish dry-run | `dart pub publish --dry-run` | **Blocked** — `analysis_options.yaml` reported modified after `flutter pub get` (exit 65); same failure mode as [CI run 34933283139](https://github.com/DevelopersCoffee/dpad_qualification/actions/runs/34933283139) |
| Example integration test | `cd example && flutter test integration_test/qualification_test.dart` | **Blocked** — no supported device on audit VM (`example` has no Linux/Web runner targets) |

**CI on `main`:** Latest workflow run is **Blocked** at the publish dry-run step (analyze/test steps completed in that run). Badge may show red until dry-run policy is fixed.

## v1.1 roadmap milestone map

Status words: **Done**, **Pending**, **Blocked**, **Deferred**, **Needs verification**.

### Track A — v1.0.1 trust patch (folded into v1.1.0 release)

| Milestone | Status | Implementation | Tests / evidence |
| --- | --- | --- | --- |
| Home → `PhysicalKeyboardKey` mapping | **Done** | `lib/src/dpad_remote_controller.dart` | Commit `1bdf39e`; `flutter test test/dpad_remote_controller_test.dart` (Home dispatch) — green on VM |
| `onFormFactorOverride`: native ≠ tablet | **Done** | `lib/src/device_qualification_overlay.dart` (`'native'`) | Commit `1bdf39e`; no dedicated widget test — **Needs verification** |
| `shared_preferences`: wire or remove | **Done** | `lib/src/qualification_settings.dart`, `pubspec.yaml` | Used in overlay load/save; overlay tests mock prefs — green on VM |
| README: devices, APIs, reports import, `showBezel` | **Pending** | `README.md` | Missing: document `autoCycle` (device table, report example, `showBezel`, `onFormFactorOverride`, and `qualification_reports.dart` import are already documented) |
| Report builder README example | **Done** | `README.md` § Headless Qualification Report | — |
| Land test / format / CI tweaks | **Done** | `.github/workflows/ci.yml`, `2122b0d`, `1bdf39e` | CI includes `example` analyze |

### Track B — test coverage

| Milestone | Status | Implementation | Tests / evidence |
| --- | --- | --- | --- |
| Overlay: panel toggle | **Done** | `lib/src/device_qualification_overlay.dart` | `test/device_qualification_overlay_test.dart` — green on VM |
| Overlay: device switch | **Done** | same | same — green on VM |
| Overlay: bezel toggle | **Pending** | Bezel UI in overlay | No overlay bezel test (simulator bezel only in `test/resolution_simulator_test.dart`) |
| Overlay: defect clipboard | **Done** | same | `DeviceQualificationOverlay copies defect report` — green on VM |
| All remote keys dispatch | **Pending** | `lib/src/dpad_remote_controller.dart` | Only Home + back/power covered; arrows/OK/menu/play not asserted |
| `autoCycle` timer (fake async) | **Pending** | `_startAutoCycle()` in overlay | Test only validates viewport list composition, not timer rotation |
| Report: `toPublicMap()`, parse edges, blocking findings | **Pending** | `lib/src/device_qualification_report.dart` | Missing: `toPublicMap()` and `DeviceQualificationPhaseStatus.parse()` edge-case tests; existing build/missing-phase tests in `test/device_qualification_report_test.dart` — green on VM |
| CI: `flutter analyze example/` | **Done** | `.github/workflows/ci.yml` | — |
| Golden: `ResolutionSimulator` bezel | **Deferred** | — | Roadmap optional; not implemented |

### Track C — honest network + report export

| Milestone | Status | Implementation | Tests / evidence |
| --- | --- | --- | --- |
| Rename to “Network Context Label” (no simulation claim) | **Done** | Overlay copy + `README.md` | Visual/copy in `device_qualification_overlay.dart` |
| `NetworkQualificationHook` (roadmap v1.2; shipped in 1.1) | **Done** | `lib/src/network_qualification_hook.dart`, overlay wiring | Minimal unit-style test in overlay test file — green on VM |
| File export JSON + Markdown | **Done** | `lib/src/report_file_export.dart`, `qualification_reports.dart` | `test/report_file_export_test.dart` — green on VM |
| Persist defect draft list | **Done** | `QualificationSettingsStore.defectDraftKey` | No test asserting draft round-trip — **Needs verification** |

### Track D — differentiation

| Milestone | Status | Implementation | Tests / evidence |
| --- | --- | --- | --- |
| Screenshot capture + watermark path | **Done** | `_captureScreenshot()` in overlay | No automated test (platform / directory dependent) — **Needs verification** |
| GitHub issue prefill URL | **Done** | `lib/src/github_issue_url.dart` | `test/github_issue_url_test.dart` — green on VM |
| `CustomSimulatedDevice` / custom viewport API | **Done** | `lib/src/resolution_simulator.dart` | Overlay + simulator tests — green on VM |
| Example `integration_test` | **Needs verification** | `example/integration_test/qualification_test.dart` | Missing: successful run on CI or maintainer VM (audit VM had no device target; add `linux`/`web` to `example` or use Android TV / Fire TV emulator) |
| Platform note: `HardwareKeyboard` desktop/web-first | **Pending** | — | Not documented in `README.md` |

### GSTACK design / DX follow-ups (from roadmap review)

| Milestone | Status | Implementation | Tests / evidence |
| --- | --- | --- | --- |
| Semantics on remote buttons | **Done** | `dpad_remote_controller.dart` | Commit `1bdf39e` |
| Snackbar on clipboard failure | **Pending** | Overlay always shows success snackbar | — |
| Empty defect list UI state | **Pending** | — | — |
| Overlay control semantics (beyond remote) | **Pending** | — | — |
| Public dartdoc | **Pending** | Some public types still lack `///` dartdoc | — |
| Example README screenshots | **Pending** | `example/README.md` | — |

### Scope explicitly NOT IN (roadmap)

| Item | Status |
| --- | --- |
| OS-level network throttling | **Deferred** |
| Apple TV / Roku presets (built-in) | **Deferred** (custom preset API **Done**) |
| GitHub OAuth issue creation | **Deferred** |
| Split overlay into separate package | **Deferred** |
| Multi-quarter CI matrix product | **Deferred** |

### On-device / downstream qualification

| Milestone | Status | Rerun steps |
| --- | --- | --- |
| Physical TV / Fire TV sign-off (e.g. Aika Stream TV) | **Needs verification** | Build host app with `DeviceQualificationOverlay`; run on Fire TV / Android TV hardware; exercise D-Pad focus, 1080p/4K presets, export defect Markdown; file phase statuses via `DeviceQualificationReportBuilder` |
| Package consumed from pub.dev in production app | **Needs verification** | Confirm downstream `pubspec` pin and overlay enabled only in QA/profile builds |

## Release posture summary

- **v1.1.0** is **published** on pub.dev and tagged in git; changelog sections for **1.0.1** and **1.1.0** describe work that landed in PR #1 / tag `v1.1.0`.
- **`main` is one commit ahead** of tag `v1.1.0` (publish workflow pin only).
- **Primary engineering blockers** before treating stabilization as **Done**: CI publish dry-run **Blocked**; publish workflow Flutter pin vs `sdk: ^3.12.0` compatibility (**Needs verification** on pinned `3.29.3`); test gaps in Track B and design follow-ups in backlog.

See `PROJECT_BACKLOG.md`, `PROJECT_EXECUTION_PLAN.md`, and `PROJECT_RELEASE_CHECKLIST.md` for next actions.
