# dpad_qualification — release checklist

Use for **future** versions after **1.1.2**. Primary path: **[justfile](justfile)** (local-first).

## Pre-release

| Step | Command / action |
| --- | --- |
| Version + changelog | Edit `pubspec.yaml` and `CHANGELOG.md` |
| Local gate | `just check` (format-check, analyze, 24 tests) |
| Dry-run | `just dry-run` (clean git tree, exit 0) |
| README / API docs | Match new behavior if any |

## Publish

| Step | Command / action |
| --- | --- |
| pub.dev | `just publish-force` (local `dart pub token`) **or** run **Publish to pub.dev** workflow manually (OIDC) |
| Confirm | https://pub.dev/packages/dpad_qualification — latest version |

## Tag & GitHub

| Step | Command / action |
| --- | --- |
| Tag + release | `just release X.Y.Z` **or** `git tag` + `gh release create` |
| Align tag target | Tag should point at commit whose `pubspec` version matches `X.Y.Z` |

## Post-release

| Step | Status for 1.1.2 |
| --- | --- |
| pub.dev live | **Done** |
| Tag `v1.1.2` | **Done** → `2e3be59` |
| GitHub Release | **Done** |
| Downstream pin `^1.1.2` | **Needs verification** (consumer repos) |
| On-device TV qual | **Needs verification** |

## Optional GitHub Actions

Workflows **do not run on push**. To re-verify in the cloud: Actions → **CI** → **Run workflow**.
