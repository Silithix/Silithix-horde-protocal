# Architecture — Horde Protocol

**Stack lock:** Godot 4.4 · GDScript · Mobile renderer · 1080×1920 portrait · `canvas_items` / `expand`  
**Package:** `com.hordeprotocol.survival`  
**Save:** `user://save.json`  
**Main scene:** `res://scenes/boot/Boot.tscn` → Hub → Run

## Scene flow
`Boot` → `Hub` → `Run` (stub) → back to Hub on cancel / end_run

## Autoloads (order)
1. `Events` — signal bus only  
2. `Save` — meta JSON  
3. `Audio` — facade (Art wires streams)  
4. `Pool` — stub (Systems implements)  
5. `Game` — app/run navigation

## Folder ownership
| Path | Owner |
|------|--------|
| `project.godot`, `autoload/`, `scenes/boot/`, `export_presets.cfg`, `.gitignore`, `.github/workflows/` | Arch |
| `scenes/hub/` shell, `scenes/run/` root stub | Arch (Systems fills Run; Art polishes Hub) |
| `scripts/player|meta`, pooling, XP, camera, damage, pause, chapter SM | Systems |
| `scripts/combat|enemies`, `data/weapons|passives|evolutions|enemies|bosses` | Combat |
| `scripts/waves`, `data/chapters|formations|crates|pickups` | Waves |
| `assets/`, HUD/menus theme, SFX/music, `CREDITS.md` | Art |
| `tests/`, `docs/EXPORT.md`, `docs/KNOWN_ISSUES.md`, checklists | QA |
| `README.md`, milestone plan, go/no-go | Lead (Chief of Staff) |

**Rule:** one file owner at a time. Coordinate in Horde Protocol room.

## Milestone A next
Systems: player move, one auto-weapon hook, one seeker enemy, XP + dummy level-up cards, death.  
Combat: Kunai L1 + Walker data/behavior.  
Art: readable placeholders + HUD chip.
