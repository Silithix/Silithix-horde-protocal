# Tests — Horde Protocol

Plan: GdUnit4 and/or headless smoke scripts. No game project yet — hooks land with Milestone A.

## Smoke targets (headless where possible)
- Boot scene loads without error
- Hub → Run scene transition
- Pool acquire/release does not grow node count after N cycles
- Chapter JSON parses; timeline events ordered by `t`
- Save round-trip (`user://save.json`)

## Manual gates
See `docs/QA_CHECKLIST.md` (device + Section 8). Those are the ship bar until automated coverage exists.

## Adding a test
1. Put under `tests/`
2. Note how to run in PR / `docs/BOT_LOG.md`
3. Failures that block ship → `docs/KNOWN_ISSUES.md`
