# dpad_qualification — project status

**Last updated:** 2026-10-24 (IST) — **v1.1 roadmap thread closed**

Historical roadmap input: 2026-09-15 v1.1 plan snapshot (superseded by shipped releases).

## Current baseline

| Item | Value |
| --- | --- |
| **pub.dev latest** | **1.1.2** — https://pub.dev/packages/dpad_qualification |
| **Published versions** | `1.0.0`, `1.1.0`, `1.1.1`, `1.1.2` |
| **`main` HEAD** | `05f79c1` — local-first `justfile`, GitHub Actions **manual dispatch only** |
| **Package version** (`pubspec.yaml`) | **1.1.2** |
| **Tags** | `v1.0.0`, `v1.1.0`, `v1.1.1` → `ecc5bc5`, `v1.1.2` → `2e3be59` |
| **GitHub Releases** | [v1.1.2](https://github.com/DevelopersCoffee/dpad_qualification/releases/tag/v1.1.2), [v1.0.0](https://github.com/DevelopersCoffee/dpad_qualification/releases/tag/v1.0.0) |
| **Key PRs** | [#1](https://github.com/DevelopersCoffee/dpad_qualification/pull/1) v1.1.0, [#3](https://github.com/DevelopersCoffee/dpad_qualification/pull/3) v1.1.1 CI, [#4](https://github.com/DevelopersCoffee/dpad_qualification/pull/4) pub OIDC, [#5](https://github.com/DevelopersCoffee/dpad_qualification/pull/5) v1.1.2 backlog |

## Local verification (source of truth)

Contributors and release owners run **`just check`** (format-check, analyze, **24 tests**). See root [`justfile`](justfile).

| Check | Recipe / command |
| --- | --- |
| Full gate | `just check` |
| Publish dry-run | `just dry-run` |
| pub.dev publish | `just publish-force` (local credentials) |
| Tag + GitHub release | `just release 1.1.x` |

GitHub Actions **CI** and **Publish to pub.dev** workflows are **`workflow_dispatch` only** (no automatic runs on push/PR/tag).

## v1.1 roadmap outcome

| Track | Status |
| --- | --- |
| Trust patch / docs honesty (A) | **Done** (shipped in 1.1.0 → 1.1.1 line) |
| Test coverage (B) | **Done** except optional golden (**Deferred**) |
| Network + report export (C) | **Done** |
| Differentiation (D) | **Done** |
| Design/DX follow-ups (P2) | **Done** |

Detail per milestone: [`CHANGELOG.md`](CHANGELOG.md), [`PROJECT_BACKLOG.md`](PROJECT_BACKLOG.md).

## Needs verification (outside repo)

| Item | Status | Rerun |
| --- | --- | --- |
| Fire TV / Android TV host-app qualification (e.g. Aika Stream TV) | **Needs verification** | QA/profile build with `DeviceQualificationOverlay`; physical device; export defect Markdown + optional `DeviceQualificationReportBuilder` phases |
| Downstream `pubspec` pin | **Needs verification** | Consumer app uses `dpad_qualification: ^1.1.2`; overlay not enabled in production store builds |

## Thread closure

- **1.1.2** published on pub.dev; **GitHub release** and tag **`v1.1.2`** published.
- **No open P0–P2 backlog** for the v1.1 track.
- **Next work** (optional): v1.2 features from deferred list, golden tests (T-8), or hardware sign-off (I-2).
