# Known Issues — Horde Protocol

Log failures here before any APK go/no-go. Fix blockers. Ship with at most minor issues.

| ID | Severity | Area | Summary | Repro | Status | Owner |
|----|----------|------|---------|-------|--------|-------|
| QA-A1 | Minor | Level-up | Multi-level one-card drop | ≥2 levels in one XP tick | Fixed `2dd6d96` + runtime OK | Systems |
| QA-A2 | Major | Pause / Hub | Esc while paused softlock | Level-up + Esc | Fixed `2dd6d96` — Esc→Hub PASS | Systems |
| QA-A3 | Perf note | Run | `get_nodes_in_group("enemy")` on spawn tick | 12-min soak | Watch | Systems |
| QA-A4 | Major | Balance / A gate | Contact melt before level-up (~8s TTK) | Hub→Play kite | Fixed 2026-09-12 — Systems `c624929` + Combat contact 5/0.55; re-smoke PASS (~1:06, cards+unpause) | Combat / Systems |
| QA-B1 | Major | Crates | Collect unverified | Walk into crate | Fixed `69f5508` — proximity + beacon; GUI toast `+GOLD (FULL HP)` PASS | Systems |
| QA-B2 | Minor | Feedback | Heal at full HP looks like no-op | Collect heal at max HP | Fixed `69f5508` — toast includes FULL HP | Systems / Art |
| QA-B4 | Balance | Hound | L1 Shard Knife one-shots Hound; Hound closes much faster than Drifter — swingy mean | Fight one Hound with knives only | Open / Combat call | Combat |
| QA-A5 | Minor | Audio | ALSA missing on QA box → dummy driver | Launch Godot here | Accepted / env | QA |

## Severity
- **Blocker** — crash, softlock, data wipe, install fail → no ship
- **Major** — core loop broken (level-up, evo, save, boss) → no ship unless cut documented
- **Minor** — polish / edge case → ship OK with note
- **Perf** — FPS < 50 on soak / node leak → Milestone D blocker

## Last audit
- Date: 2026-09-12
- Build: Milestone A after QA-A4 mitigations (Godot 4.4.1 GUI)
- Method: interactive re-smoke; screenshots `build/qa-smoke2/`
- Results:
  - Hub→Play: PASS
  - Survive ≥20s: PASS (~1:06)
  - Level-up cards + pick + unpause: PASS
  - Esc→Hub: PASS
- Milestone A runtime: **PASS** (kite + shoot + XP + level-up + abandon)
- APK gate: **NO-GO** until D/E

## Milestone B slice 1 audit (2026-09-12)
- Commit smoked: `08fe569` (plus current main)
- Pause Resume/Hub: PASS
- Level-up → Shard Knives upgrade card: PASS (levels 2–4)
- Esc during level-up → Hub: PASS
- Crate: seen, not collected (QA-B1)
- APK: NO-GO (Lead hold on D/E)

## Crate re-smoke (2026-09-12, f1a578d)
- Result: **FAIL** (no confirmed collect effect)
- Pulse Halo ring observed mid-run (Combat B present)
- Hound brown vs crate brown nearly identical — high mis-ID risk
- APK: NO-GO (Lead hold)

## 2026-09-12 smoke b1d (`69f5508`)
- Crate beside Rook + toast: **PASS** (`+GOLD (FULL HP)`)
- Screenshots: `build/qa-smoke-b1d/`
- QA-B1 / QA-B2 closed
- APK: NO-GO (Lead hold on D/E)
