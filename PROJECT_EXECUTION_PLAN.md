# dpad_qualification — execution plan

Ordered work to close gaps between the 2026-09-15 v1.1 roadmap snapshot and a trustworthy **post-1.1.0** maintenance line. **No pub.dev publish** in this docs-only pass.

## Phase 0 — Baseline lock (complete for audit)

1. Record HEAD, tags, pub.dev versions → `PROJECT_STATUS.md`.
2. Run format, analyze, unit tests on a Dart **≥ 3.12** Flutter SDK → documented in `PROJECT_STATUS.md`.
3. Map each roadmap bullet to code + tests → tables in `PROJECT_STATUS.md`.

## Phase 1 — Restore CI trust (P0)

| Step | Action | Owner | Exit criteria |
| --- | --- | --- | --- |
| 1.1 | Reproduce CI failure locally: `flutter pub get && dart pub publish --dry-run` | Eng | Match exit 65 + `analysis_options.yaml` warning |
| 1.2 | Fix: commit intentional `analysis_options.yaml` exclude **or** stop mutating tree in CI (pin lockfiles / skip dry-run mutation) | Eng | `dart pub publish --dry-run` exit 0 on clean tree |
| 1.3 | Align `.github/workflows/publish.yml` Flutter version with `sdk: ^3.12.0` (verify with `flutter --version`) | Eng | `flutter pub get` succeeds on publish job image |
| 1.4 | Re-run GitHub Actions on `main` | Eng | CI badge green |

## Phase 2 — Close Track B test debt (P1)

Execute in order (each step adds tests only; keep behavior unchanged unless bugs found):

1. Overlay bezel toggle test.
2. Full remote key dispatch matrix test.
3. `autoCycle` timer test with fake async.
4. Report builder: `parse()`, `toPublicMap()`, blocking/waived edge cases.
5. Defect draft persistence test via mocked `SharedPreferences`.

**Verification:** `flutter test --coverage`; target maintain or increase coverage on `device_qualification_overlay.dart` and `device_qualification_report.dart`.

## Phase 3 — Documentation honesty (P2)

1. README: `autoCycle`, platform limits for keyboard injection, QA-only clipboard note (security item from eng review).
2. Dartdoc pass on exported public types in `lib/dpad_qualification.dart` and `lib/qualification_reports.dart`.
3. Example README: one screenshot of overlay + device picker.

## Phase 4 — Integration path (P3)

1. Add `linux` or `web` support to `example/` **or** document Android TV emulator command for integration test.
2. Wire optional CI job: `flutter test integration_test/qualification_test.dart -d linux` (if platform added).
3. Downstream: document recommended pattern for Aika Stream TV / Fire TV — overlay in profile builds, headless reports in CI.

## Phase 5 — Release hygiene (when explicitly requested)

Use `PROJECT_RELEASE_CHECKLIST.md`. For a **patch** after docs/tests (e.g. 1.1.1):

- Changelog section for CI + test-only changes.
- Tag only after CI green and dry-run clean.
- **Do not merge docs PR into release tag** without separate release approval.

## Out of scope for this plan

- pub.dev publish (forbidden for this Cloud Agent task).
- Real network throttling, OAuth GitHub issues, package split (see `PROJECT_BACKLOG.md` Deferred).
