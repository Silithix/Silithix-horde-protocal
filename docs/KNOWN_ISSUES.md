# Known Issues — Horde Protocol

Log failures here before any APK go/no-go. Fix blockers. Ship with at most minor issues.

| ID | Severity | Area | Summary | Repro | Status | Owner |
|----|----------|------|---------|-------|--------|-------|
| QA-A1 | Minor | Level-up | Multi-level one-card drop | ≥2 levels in one XP tick | Fixed `2dd6d96` + runtime OK | Systems |
| QA-A2 | Major | Pause / Hub | Esc while paused softlock | Level-up + Esc | Fixed `2dd6d96` — Esc→Hub PASS | Systems |
| QA-A3 | Perf note | Run | `get_nodes_in_group("enemy")` on spawn tick | 12-min soak | Watch | Systems |
| QA-A4 | Major | Balance / A gate | Contact melt before level-up (~8s TTK) | Hub→Play kite | Fixed 2026-09-12 — Systems `c624929` + Combat contact 5/0.55; re-smoke PASS (~1:06, cards+unpause) | Combat / Systems |
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
