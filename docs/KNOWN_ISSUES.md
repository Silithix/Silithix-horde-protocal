# Known Issues — Horde Protocol

Log failures here before any APK go/no-go. Fix blockers. Ship with at most minor issues.

| ID | Severity | Area | Summary | Repro | Status | Owner |
|----|----------|------|---------|-------|--------|-------|
| QA-A1 | Minor | Level-up | Multi-level in one XP tick only shows one card (`show_level_up` bails if `_open`) | Collect gem that crosses ≥2 levels | Fixed 2026-09-12 — queue in LevelUpUI | Systems |
| QA-A2 | Major* | Pause / Hub | `Run` Esc → `go_to_hub` never clears `get_tree().paused`. Softlock if tree is paused (e.g. abandon during level-up once Esc is wired under pause) | Level-up open + Esc/back if input reaches Run | Fixed 2026-09-12 — force_close + unpause before hub; Run PROCESS_MODE_ALWAYS | Systems |
| QA-A3 | Perf note | Run | `_alive_enemy_count` uses `get_nodes_in_group("enemy")` on spawn tick — OK for A; fail Milestone D if left in hot path | 12-min soak | Watch | Systems |

\*Was major if Esc fired while paused. Mitigated in `2dd6d96` (Run always + force_close). Still needs Godot Hub→Play confirmation.

## Severity
- **Blocker** — crash, softlock, data wipe, install fail → no ship
- **Major** — core loop broken (level-up, evo, save, boss) → no ship unless cut documented
- **Minor** — polish / edge case → ship OK with note
- **Perf** — FPS < 50 on soak / node leak → Milestone D blocker

## Last audit
- Date: 2026-09-12
- Build: local Milestone A (no APK)
- Method: static — no Godot binary on shared computer
- JSON: all `data/**/*.json` parse OK
- Scenes: Boot/Hub/Run/Player/Drifter/ShardKnives/LevelUpUI/RunHud present
- Milestone A runtime Hub→Play: **unverified** (need editor/device)
- QA-A1/A2: code review of `2dd6d96` — looks closed; runtime still pending
- APK gate: **NO-GO** until D/E
