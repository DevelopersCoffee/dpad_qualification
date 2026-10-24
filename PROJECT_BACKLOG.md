# dpad_qualification — backlog

Status words: **Done**, **Pending**, **Blocked**, **Deferred**, **Needs verification**.

**Last updated:** 2026-10-24 — v1.1 track **closed**; pub.dev **1.1.2**.

## P0 — repo health

| ID | Item | Status |
| --- | --- | --- |
| H-1 | Verification on `main` | **Done** — `just check` (24 tests); GH Actions optional manual |
| H-2 | Publish workflow SDK / OIDC | **Done** — `dart-lang/setup-dart` publish workflow; CLI or manual dispatch |
| H-3 | `analysis_options.yaml` exclude | **Done** |

## P1 — roadmap tests (Track B)

| ID | Item | Status |
| --- | --- | --- |
| T-1 … T-7 | Overlay, remote, report, navigation tests | **Done** |
| T-8 | Golden bezel | **Deferred** |

## P2 — docs & DX

| ID | Item | Status |
| --- | --- | --- |
| D-1 … D-7 | README, overlay UX, semantics | **Done** |
| D-8 | Document `justfile` in README | **Done** (see Contributing) |

## P3 — integration & downstream

| ID | Item | Status |
| --- | --- | --- |
| I-1 | Example smoke test | **Done** — `example/test/qualification_smoke_test.dart`; run via `just test` |
| I-2 | Fire TV / Android TV hardware qual | **Needs verification** |
| I-3 | GitHub Release notes for v1.1.x | **Done** for **v1.1.2**; optional **v1.1.1** release page |

## Deferred (roadmap OUT scope)

OS network throttling, built-in Apple/Roku presets, GitHub OAuth issue creation, package split, CI matrix product.

## Next version (when scoped)

1. Bump `pubspec` + `CHANGELOG.md`.
2. `just check` && `just dry-run`.
3. `just publish-force` or tag + manual **Publish to pub.dev** workflow.
4. `just release X.Y.Z` for GitHub release + tag.
