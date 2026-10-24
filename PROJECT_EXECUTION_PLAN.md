# dpad_qualification — execution plan

**Status:** v1.1 roadmap **complete** as of **1.1.2** (2026-10-16 pub.dev, docs/tooling through 2026-10-23).

This document is retained for history. Active process is in the **[justfile](justfile)** and **[PROJECT_RELEASE_CHECKLIST.md](PROJECT_RELEASE_CHECKLIST.md)**.

## Completed phases (summary)

1. **Trust + CI** — 1.1.1: analysis_options, Flutter 3.47.7, publish dry-run (PR #3).
2. **pub.dev OIDC** — reusable publish workflow (PR #4).
3. **Backlog** — tests, overlay UX, docs, smoke test (PR #5 → **1.1.2**).
4. **Local-first** — `justfile`, Actions manual-only (`05f79c1`).
5. **Release** — CLI publish **1.1.2**, tag + GitHub Release **v1.1.2**.

## Optional follow-ups (not blocking thread close)

- **T-8:** golden tests for simulator bezel.
- **I-2:** hardware Fire TV / Android TV qualification with a host app.
- **GitHub Release** page for **v1.1.1** (pub.dev already has 1.1.1).
- Deferred roadmap items (network throttling, OAuth issues, etc.) — see **PROJECT_BACKLOG.md**.
