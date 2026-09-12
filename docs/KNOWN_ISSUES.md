# Known Issues — Horde Protocol

Log failures here before any APK go/no-go. Fix blockers. Ship with at most minor issues.

| ID | Severity | Area | Summary | Repro | Status | Owner |
|----|----------|------|---------|-------|--------|-------|
| QA-A1 | Minor | Level-up | Multi-level in one XP tick only shows one card | Collect gem that crosses ≥2 levels | Fixed 2026-09-12 (`2dd6d96`) — code review OK; runtime level-up still unverified | Systems |
| QA-A2 | Major* | Pause / Hub | Esc→hub while paused softlock risk | Level-up open + Esc | Fixed 2026-09-12 (`2dd6d96`) — Esc→Hub PASS in smoke | Systems |
| QA-A3 | Perf note | Run | `get_nodes_in_group("enemy")` on spawn tick | 12-min soak | Watch | Systems |
| QA-A4 | Major | Balance / A gate | Contact damage melts Rook before level-up; Hub→Play smoke never reached cards (~8s TTK, HP 100→0) | Hub→Play, stand/kite normally | Open | Combat / Systems |
| QA-A5 | Minor | Audio | ALSA missing on QA box — dummy audio driver (expected on this machine) | Launch Godot here | Accepted / env | QA |

\*Mitigated in code; Esc→Hub confirmed in 2026-09-12 GUI smoke.

## Severity
- **Blocker** — crash, softlock, data wipe, install fail → no ship
- **Major** — core loop broken (level-up, evo, save, boss) → no ship unless cut documented
- **Minor** — polish / edge case → ship OK with note
- **Perf** — FPS < 50 on soak / node leak → Milestone D blocker

## Last audit
- Date: 2026-09-12
- Build: local Milestone A @ `086ea35`+ (Godot 4.4.1 GUI smoke)
- Method: interactive Hub→Play on shared box (`/workspace/tools/godot/godot`)
- Screenshots: `build/qa-smoke/*.webp`
- Results:
  - Hub boot: PASS
  - Play → Rook + Drifters: PASS
  - Knives fire / kills / XP gems: PASS
  - Level-up cards: **NOT REACHED** (QA-A4)
  - Esc → Hub: PASS (no softlock)
  - Death → Hub: PASS
- Milestone A runtime: **CONDITIONAL** — loop boots and returns; level-up unverified
- APK gate: **NO-GO** until D/E
