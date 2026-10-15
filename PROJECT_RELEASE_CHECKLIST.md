# dpad_qualification — release checklist

Use before tagging and publishing. **v1.1.0 is already on pub.dev** (2026-09-15); this checklist applies to **future** tags (e.g. 1.1.1+) and documents current gaps.

## Pre-release

| Step | Status | Evidence / notes |
| --- | --- | --- |
| Version bumped in `pubspec.yaml` | **N/A** (still `1.1.0` on `main`) | `pubspec.yaml` |
| `CHANGELOG.md` updated for target version | **Pending** for next release | Last entry **1.1.0** |
| `dart format` clean | **Done** (2026-10-15 VM) | exit 0 |
| `flutter analyze --fatal-infos` (root) | **Done** | exit 0 |
| `flutter analyze --fatal-infos` (example) | **Done** | exit 0 |
| `flutter test` (all unit/widget) | **Done** — 15/15 | 2026-10-15 VM, Flutter 3.47.7 |
| Example integration test | **Needs verification** | Requires device target; see `PROJECT_STATUS.md` |
| `dart pub publish --dry-run` clean (no git dirty warnings) | **Blocked** | CI + local: `analysis_options.yaml` modified warning → exit 65 |
| GitHub Actions CI green | **Blocked** | Latest `main` run failed on dry-run step |
| Publish workflow Flutter matches SDK constraint | **Needs verification** | `publish.yml` → `3.29.3` vs `sdk: ^3.12.0` |
| README / public API docs accurate | **Partial** | `autoCycle`, platform limits still **Pending** |
| Security note: QA-only overlay / clipboard | **Pending** | Eng review item; not in README |

## Tag & GitHub

| Step | Status | Evidence |
| --- | --- | --- |
| Tag `vX.Y.Z` on release commit | **Done** for 1.1.0 | `v1.1.0` → `51dd887` |
| GitHub Release with notes | **Pending** for 1.1.0 | Only `v1.0.0` release listed |
| Merge release PR | **Done** | [#1](https://github.com/DevelopersCoffee/dpad_qualification/pull/1) |

## pub.dev (manual policy for this task)

| Step | Status | Evidence |
| --- | --- | --- |
| Package published | **Done** @ **1.1.0** | pub.dev API, 2026-09-15 |
| Publish workflow succeeded on tag | **Needs verification** | Workflow run for `v1.1.0` was **cancelled** (6h); package still appeared on pub.dev |
| **Do not publish** from Cloud Agent docs PR | **Done** | Docs-only branch |

## Post-release / downstream

| Step | Status | Rerun |
| --- | --- | --- |
| Host app pins `dpad_qualification: ^1.1.0` | **Needs verification** | Check consumer `pubspec` |
| Fire TV / Android TV hardware qualification | **Needs verification** | QA build + physical device + overlay defect export |
| CI matrix using headless reports | **Pending** | Integrate `DeviceQualificationReportBuilder` + `writeQualificationReportFiles` in consumer pipeline |

## Suggested commands (maintainer VM)

```bash
flutter pub get
cd example && flutter pub get && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
cd example && flutter analyze --fatal-infos && cd ..
flutter test --coverage
dart pub publish --dry-run
git status   # must be clean before tag
```

For integration test (after adding a supported `example` device target):

```bash
cd example
flutter test integration_test/qualification_test.dart -d <device_id>
```
