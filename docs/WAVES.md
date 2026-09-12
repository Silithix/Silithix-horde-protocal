# Waves — Chapter director contract

Owned by **Waves**. Runtime reader owned by **Systems**.

## Files
- `data/chapters/chapter_01.json`
- `data/formations/formations.json`
- `data/crates/crate_table.json`
- `data/pickups/pickup_table.json`

## Event actions
| action | meaning |
|--------|---------|
| `spawn` | one-shot pack (`enemy`+`count` or `composition`) |
| `spawn_loop` | repeat every `every_sec` until `until_t` |
| `horde` | dense authored dump (prefer ring / flood) |
| `boss_warn` | banner + optional trash clear/freeze |
| `boss` | spawn boss; `chapter_clear_on_kill` on final |

## Feel targets (playtest these, not spawn counts)
1. 0:00–0:30 — weak, must kite
2. ~2:00 — first “oh shit” ring
3. 5:00 / 10:00 / 15:00 — readable boss exams
4. Budget dips on boss windows so patterns read
5. If AFK @8:00 lives → budget too low or damage too high

## Milestone hooks
- **B:** ship events through `t=120` (opener + first horde) as playable 2-min slice.
- **C:** full 900s + crates + chests wired.

## Enemy ids (Combat owns defs)
Trash: `drifter`, `hound`, `tox_spout`, `plated_drifter`, `drift_mote`  
Elites: `drifter_elite`, `tox_spout_elite`, `plated_drifter_elite`  
Minis: `railhorn_mini` @ 3:00 and 8:00  
Bosses: `rico_bloom` @ 5:00, `railhorn` @ 10:00, `mortar_host` @ 15:00
