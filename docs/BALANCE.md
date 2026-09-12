# Balance — Horde Protocol

Owned by **Combat**. Starting numbers for Milestone A+; Waves owns spawn density/timeline.

## ID mapping (Habby-inspired → original IP)

| Role | Habby-ish reference (do not ship names) | Our id | Display |
|------|------------------------------------------|--------|---------|
| Starter knives | Kunai | `shard_knives` | Shard Knives |
| Trash melee | Walker | `drifter` | Drifter |
| Fast melee | Runner / dog | `hound` | Hound |
| Ranged | Spitter | `tox_spout` | Tox Spout |
| Armored melee | Armored walker | `plated_drifter` | Plated Drifter |
| Swarm fly | Fly | `drift_mote` | Drift Mote |
| Elite melee | Elite walker | `drifter_elite` | Drifter Elite |
| Elite ranged | Elite spitter | `tox_spout_elite` | Tox Spout Elite |
| Mini-boss | — | `railhorn_mini` | Railhorn Mini |
| Boss 5:00 | Bouncebloom-style | `rico_bloom` | Rico Bloom |
| Boss 10:00 | Charger | `railhorn` | Railhorn |
| Boss 15:00 | Summoner / artillery | `mortar_host` | Mortar Host |

Never use Habby/Kunai/Walker names in player-facing strings or shipped ids.

## Milestone A starting numbers

### Shard Knives (`data/weapons/shard_knives.json`)
| Level | damage | cooldown_s | projectile_count | pierce | projectile_speed |
|------:|-------:|-----------:|-----------------:|-------:|-----------------:|
| 1 | 12 | 0.7 | 1 | 0 | 420 |
| 2 | 16 | 0.65 | 1 | 0 | 440 |
| 3 | 18 | 0.6 | 2 | 0 | 450 |
| 4 | 22 | 0.55 | 2 | 1 | 460 |
| 5 | 26 | 0.5 | 3 | 1 | 480 |

Feel: two L1 knives kill one Drifter. Misses teach kite.

### Drifter (`data/enemies/drifter.json`)
| Field | Value |
|-------|------:|
| hp | 18 |
| move_speed_px_s | 70 |
| contact_damage | 8 |
| contact_tick_s | 0.4 |
| gold_drop | 1 |
| xp | 1 gem (runtime) |

### Boss ids (data stubs / Waves timeline)
- `rico_bloom` @ 5:00
- `railhorn` @ 10:00
- `mortar_host` @ 15:00
- `railhorn_mini` @ 3:00 and 8:00

## Change log

| Date | Change |
|------|--------|
| 2026-09-12 | Milestone A: locked Shard Knives L1–L5 + Drifter numbers; id map walker→drifter, kunai→shard_knives; boss ids rico_bloom / railhorn / mortar_host / railhorn_mini. |
