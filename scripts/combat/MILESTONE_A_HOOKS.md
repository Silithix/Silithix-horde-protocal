# Milestone A — Combat → Systems wiring

Combat shipped **Shard Knives** + **Drifter**. Swap Systems stand-ins as below.  
Do **not** edit Combat-owned paths from Systems; Systems owns `Run.gd` / `Player.gd` / Pool warm sites.

## Conventions (locked with Systems)
| Concern | Value |
|---------|--------|
| Enemy groups | `"enemy"` + `"enemies"` (dual-tag; weapon queries both) |
| Player group | `"player"` |
| Run group | `"run_root"` |
| Damage API | `apply_damage(amount, source)` |
| Contact | `Contact` Area2D in groups `"enemy_contact"` + meta `contact_damage` / `contact_tick_s` (Player hurtbox already reads these) |
| Death | `Events.enemy_killed.emit(self, gold)` then `run_root.spawn_xp_gem(pos, xp)` if present, then `Pool.release` |
| Pool key | `&"drifter"` |

## 1) Attach Shard Knives to the player

```gdscript
const SHARD_KNIVES := preload("res://scenes/combat/ShardKnivesWeapon.tscn")

# After player is in tree (e.g. Run._ready / spawn_player):
var wpn := SHARD_KNIVES.instantiate()
player.add_child(wpn)
wpn.setup(player)          # required
# Optional later: wpn.set_level(n)
```

Weapon auto-fires on cooldown at nearest node in group `"enemy"`.  
Projectiles parent under `run_root/Projectiles` when that node exists.

## 2) Swap TempSeeker → Drifter

Replace Systems temp seeker scene + pool warm:

```gdscript
const DRIFTER_SCENE := preload("res://scenes/enemies/Drifter.tscn")

# Was: Pool.warm(&"temp_seeker", TEMP_SEEKER_SCENE, N)
Pool.warm(&"drifter", DRIFTER_SCENE, 64)  # count as you prefer

# Spawn (same activate signature as TempSeeker):
var e := Pool.acquire(&"drifter", enemies_parent)  # or Entities / Enemies node
if e:
    e.activate(spawn_pos, player)
```

If you instantiate without Pool:

```gdscript
var d := DRIFTER_SCENE.instantiate()
enemies_parent.add_child(d)
d.setup(player)                 # loads data/enemies/drifter.json
# or: d.setup(player, "drifter")
d.global_position = spawn_pos
# activate(pos, player) also works and calls on_pool_acquire
```

**Drop-in checklist vs TempSeeker**
- [ ] `SEEKER_SCENE` / preload → `res://scenes/enemies/Drifter.tscn`
- [ ] `Pool.warm(&"drifter", …)` (and spawn acquire key `&"drifter"`)
- [ ] Stop warming/acquiring `&"temp_seeker"` once swapped
- [ ] Keep player in group `"player"`; Drifter is in `"enemy"` + `"enemies"`

## 3) Public APIs

### `ShardKnivesWeapon`
- `setup(owner: Node2D) -> void`
- `set_level(level: int) -> void`

### `Drifter` / `EnemyBase`
- `setup(target: Node2D, data_id:="drifter") -> void`
- `activate(pos: Vector2, player: Node2D) -> void` — Pool-friendly entry (same as TempSeeker)
- `apply_damage(amount: float, source: Node = null) -> void`
- `on_pool_acquire() / on_pool_release()` — Pool calls these

### Data loaders
- `CombatData.load_weapon(id)` → `res://data/weapons/<id>.json`
- `CombatData.load_enemy(id)` → `res://data/enemies/<id>.json`

## 4) What Combat will NOT touch
- `scenes/run/Run.gd`
- `scripts/player/*`
- `autoload/*` / `project.godot`
- Systems damage / XP / Pool implementation
