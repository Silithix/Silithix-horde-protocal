# Milestone B — Combat → Systems wiring

Combat shipped **Hound**, **Tox Spout** (+ bolt), **Pulse Halo**, **Orbit Blades**, and **Plated Drifter**.  
Do **not** edit Combat-owned paths from Systems. Systems owns `Run.gd` / `Player.gd` / Pool warm / level-up cards.

Conventions stay locked with Milestone A (`MILESTONE_A_HOOKS.md`).

## Conventions (locked)
| Concern | Value |
|---------|--------|
| Enemy groups | `"enemy"` + `"enemies"` |
| Player group | `"player"` |
| Run group | `"run_root"` |
| Damage API | `apply_damage(amount, source)` (`take_damage` alias on enemies) |
| Contact | `Contact` Area2D in `"enemy_contact"` + meta `contact_damage` / `contact_tick_s` |
| Death | `Events.enemy_killed` → optional `run_root.spawn_xp_gem` → `Pool.release(_pool_key())` |
| Pool keys | `&"hound"` · `&"tox_spout"` · `&"plated_drifter"` · (existing `&"drifter"`) |
| Pool const | Do **not** redeclare `const POOL_KEY` on subclasses — Godot 4.4 errors. Keys live in `_pool_key()`. |

## 1) Warm + spawn Hound / Tox Spout / Plated Drifter

```gdscript
const HOUND_SCENE := preload("res://scenes/enemies/Hound.tscn")
const TOX_SPOUT_SCENE := preload("res://scenes/enemies/ToxSpout.tscn")
const PLATED_DRIFTER_SCENE := preload("res://scenes/enemies/PlatedDrifter.tscn")

# Next to existing Pool.warm(&"drifter", …):
Pool.warm(&"hound", HOUND_SCENE, 32)
Pool.warm(&"tox_spout", TOX_SPOUT_SCENE, 24)
Pool.warm(&"plated_drifter", PLATED_DRIFTER_SCENE, 16)

func _spawn_hound() -> void:
    var e := Pool.acquire(&"hound", entities)  # Entities / Enemies node
    if e:
        e.activate(spawn_pos, player)

func _spawn_tox_spout() -> void:
    var e := Pool.acquire(&"tox_spout", entities)
    if e:
        e.activate(spawn_pos, player)

func _spawn_plated_drifter() -> void:
    var e := Pool.acquire(&"plated_drifter", entities)
    if e:
        e.activate(spawn_pos, player)
```

Same `activate(pos, player)` signature as TempSeeker / Drifter.  
Without Pool: `instantiate()` → add_child → `setup(player)` or `activate(pos, player)`.

**Suggested mix (until Waves owns the timeline):** keep Drifter as the bulk; sprinkle Hounds as closers; Tox Spouts after ~1:00 on the edges (they stop at ~280px, telegraph 0.25s, spit a purple bolt); introduce Plated Drifters as slow sponges after Boss 1 / mid-run (hp 55, speed 55, steel tint).

## 2) Offer Pulse Halo as a level-up card / attach

Scene: `res://scenes/combat/PulseHaloWeapon.tscn`  
API (same as Shard Knives): `setup(owner: Node2D)` · `set_level(level: int)`

```gdscript
const PULSE_HALO := preload("res://scenes/combat/PulseHaloWeapon.tscn")

# LevelUpUI card (first offer = attach, later = upgrade):
# {"id": "pulse_halo", "label": "Pulse Halo\nDamaging ring"}

var _halo: Node = null

func _offer_or_upgrade_pulse_halo() -> void:
    if _halo == null or not is_instance_valid(_halo):
        _halo = PULSE_HALO.instantiate()
        player.add_child(_halo)
        _halo.setup(player)          # required — starts L1 ticks
    elif _halo.has_method("set_level"):
        var lv := int(_halo.get("level")) if _halo.get("level") != null else 1
        _halo.call("set_level", lv + 1)
```

Halo is `self_aura`: follows `owner`, ticks every `cooldown_s` (0.45s at L1), `apply_damage` to live enemies inside `96 * area_scale` px. Ring draws itself (cyan). Parent under the player (or call `setup` and it will snap to owner).

Does **not** replace Shard Knives — second weapon slot.

## 3) Offer Orbit Blades as a level-up card / attach

Scene: `res://scenes/combat/OrbitBladesWeapon.tscn`  
API: `setup(owner: Node2D)` · `set_level(level: int)`

```gdscript
const ORBIT_BLADES := preload("res://scenes/combat/OrbitBladesWeapon.tscn")

# LevelUpUI card (first offer = attach, later = upgrade):
# {"id": "orbit_blades", "label": "Orbit Blades\nSpinning saws"}

var _orbit: Node = null

func _offer_or_upgrade_orbit_blades() -> void:
    if _orbit == null or not is_instance_valid(_orbit):
        _orbit = ORBIT_BLADES.instantiate()
        player.add_child(_orbit)
        _orbit.setup(player)         # required — builds L1 blades
    elif _orbit.has_method("set_level"):
        var lv := int(_orbit.get("level")) if _orbit.get("level") != null else 1
        _orbit.call("set_level", lv + 1)
```

Orbit Blades: 1–3 `Area2D` blades on a fixed radius (`orbit_radius_px` from JSON). Spins continuously (`projectile_speed` = deg/s). Damage is **contact ICD** (~0.22s) via `apply_damage` on groups `"enemy"` / `"enemies"` — JSON `cooldown_s` is unused. Parent under the player. Counts toward the 6-weapon hard cap.

Does **not** replace Shard Knives / Pulse Halo — another weapon slot.

## 4) Public APIs

### `Hound` / `ToxSpout` / `PlatedDrifter` / `EnemyBase`
- `setup(target: Node2D, data_id:=…) -> void`
- `activate(pos: Vector2, player: Node2D) -> void`
- `apply_damage(amount: float, source: Node = null) -> void`
- `is_alive() -> bool`
- `on_pool_acquire() / on_pool_release()`

### `PulseHaloWeapon` / `OrbitBladesWeapon`
- `setup(owner: Node2D) -> void`
- `set_level(level: int) -> void`

### `ToxSpoutProjectile` (thin, not pooled)
- `launch(origin, dir, damage, speed, source)`
- Hits group `"player"` → `apply_damage` if present, else `Events.player_damaged`
- Parents under `run_root/Projectiles` when that node exists, else `Entities`

### Data
- Hound → `data/enemies/hound.json` (hp 20, speed 110, contact 6/0.45 — QA-B4)
- Tox Spout → `data/enemies/tox_spout.json` (hp 16, bolt 10 / 220 / 1.6s / telegraph 0.25s)
- Plated Drifter → `data/enemies/plated_drifter.json` (hp 55, speed 55, contact 10)
- Pulse Halo → `data/weapons/pulse_halo.json` (L1–L5 damage / cooldown / area_scale)
- Orbit Blades → `data/weapons/orbit_blades.json` (L1–L5 damage / blade count 1–3 / radius / spin)

## 5) What Combat will NOT touch
- `scenes/run/Run.gd`
- `scripts/player/*`
- `autoload/*` / `project.godot`
- Systems damage / XP / Pool / level-up implementation
