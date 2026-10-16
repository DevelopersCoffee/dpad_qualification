# dpad_qualification — backlog

Status words: **Done**, **Pending**, **Blocked**, **Deferred**, **Needs verification**.

Last updated after **1.1.2** prep (2026-10-16).

## P0 — repo health

| ID | Item | Status | Notes |
| --- | --- | --- | --- |
| H-1 | CI passing on `main` | **Done** | Flutter **3.47.7**; dry-run clean with committed `analysis_options.yaml` exclude |
| H-2 | Publish workflow SDK match | **Done** | `dart-lang/setup-dart` reusable publish workflow @ v1 |
| H-3 | `analysis_options.yaml` exclude committed | **Done** | Since **1.1.1** |

## P1 — roadmap test gaps (Track B)

| ID | Item | Status |
| --- | --- | --- |
| T-1 | Overlay bezel toggle | **Done** |
| T-2 | All remote keys dispatch | **Done** |
| T-3 | `autoCycle` timer | **Done** |
| T-4 | Report `parse()` edge cases | **Done** |
| T-5 | `toPublicMap()` / blocking findings | **Done** |
| T-6 | Defect draft persistence | **Done** |
| T-7 | TV `navigationMode` assertion | **Done** |
| T-8 | Golden bezel | **Deferred** |

## P2 — docs & DX

| ID | Item | Status |
| --- | --- | --- |
| D-1 | README `autoCycle` | **Done** |
| D-2 | README platform / keyboard limits | **Done** |
| D-3 | Dartdoc on public API | **Done** (library + existing type docs) |
| D-4 | Example README screenshots | **Done** (capture instructions; assets optional) |
| D-5 | Clipboard failure snackbar | **Done** |
| D-6 | Empty defect draft hint | **Done** |
| D-7 | Overlay semantics | **Done** |

## P3 — integration & downstream

| ID | Item | Status |
| --- | --- | --- |
| I-1 | Example smoke test on CI | **Done** (`example/test/qualification_smoke_test.dart`) |
| I-2 | Fire TV / Android TV hardware qual (Aika, etc.) | **Needs verification** |
| I-3 | GitHub Release notes for v1.1.x | **Pending** |

## Deferred (roadmap OUT scope)

Unchanged — OS network throttling, built-in Apple/Roku presets, GitHub OAuth, package split, CI matrix product.

## Next publish

**1.1.2** on branch (tests + UX + docs + CI). Publish via CLI or tag after merge (user/agent).
