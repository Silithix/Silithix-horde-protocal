# QA / Release Gate — Horde Protocol

Owner: QA. Final APK go/no-go with Lead / Chief of Staff.

Package: `com.hordeprotocol.survival`  
Target: portrait Android, ARM64, offline, Godot 4.3+

## Device / install checklist
- [ ] Fresh install on ARM64 (device or emulator)
- [ ] No unexpected permissions (no contacts / location)
- [ ] Cold boot → title → hub under **4s** (emulator OK for gate)
- [ ] Android back button pauses run
- [ ] Background app ≥30s → resume run without softlock
- [ ] Touch targets ≥ **48dp** (level-up cards, pause, hub Play)
- [ ] Notch / safe-area padding (HP / timer not clipped)
- [ ] Install over previous build — save not wiped unless migration documented
- [ ] Immersive / portrait locked

## Section 8 script (must pass before APK done)
1. [ ] Cold boot to hub < 4s
2. [ ] Start run, kite circle 20s — weapons clear single walkers if kiting
3. [ ] Level to 3 — world pauses for cards; duplicate weapon upgrades
4. [ ] Force boss (cheat) — banner, pattern, chest, unpause
5. [ ] Fill 6 weapons — no 7th weapon offered (passives/gold/heal only)
6. [ ] Trigger evolution — base gone, evo present, attacks changed
7. [ ] Die → results → hub; gold persists after kill-app-reopen
8. [ ] Win / cheat to 15:00 — victory state, not freeze
9. [ ] 12-min soak: FPS ≥ 50 (medium quality), enemy cap hit, no orphan node climb
10. [ ] APK install over previous build — no silent data wipe

## Always verify
- [ ] Fresh install → title → hub → run → die/win → hub, no crash
- [ ] Level-up cannot softlock
- [ ] Evolution replaces weapon
- [ ] 10+ min run: no node leak / freeze (pooling)
- [ ] Repo builds from clean clone per `docs/EXPORT.md`

## Perf budget (fail = Milestone D block)
- Live enemies capped (~250); extras queued
- Live gems capped / merged
- No per-frame `get_nodes_in_group` in `_process`
- 60 FPS target mid-range phone with ≥200 enemies

## Go / no-go
| Gate | Result | Notes |
|------|--------|-------|
| Milestone A playable | ☐ CONDITIONAL | Hub→Play/Esc/death PASS; level-up blocked by QA-A4 |
| Milestone D phone APK | ☐ | |
| Section 8 all green | ☐ | |
| Known blockers = 0 | ☐ | see KNOWN_ISSUES.md |
| **Ship APK** | **NO-GO** | A level-up unverified; D/E not started |

## How to report a fail
Append to `docs/KNOWN_ISSUES.md` with severity, repro, build hash/tag. Ping Lead for blockers.
