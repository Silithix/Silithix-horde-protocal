# BOT_LOG

## 2026-09-12 — Arch — Milestone A scaffold

**Files touched:**
- `project.godot` (4.4, Mobile, 1080×1920, canvas_items/expand, main=`scenes/boot/Boot.tscn`)
- `autoload/Events.gd`, `Save.gd`, `Audio.gd`, `Pool.gd`, `Game.gd`
- `scenes/boot/Boot.tscn|+gd`, `scenes/hub/Hub.tscn|+gd`, `scenes/run/Run.tscn|+gd`
- `icon.svg`, `.gitignore`, `export_presets.cfg` (Android arm64, `com.hordeprotocol.survival`)
- `.github/workflows/android-apk.yml` (stub)
- `docs/ARCHITECTURE.md`, folder conventions under `scripts/`, `scenes/ui/`, `data/characters/`

**How to test:** Open `/workspace/horde-protocol` in Godot 4.4 → F5 → Boot splash → Hub → Play → Run stub. Esc/back returns to Hub.

**Leftover risk:** No gameplay yet. Pool stub returns null on miss until Systems warms pools. Keystore empty in export preset.

**Handoff:** @Systems @Combat @Art — clear to take your paths. Milestone A only.

## 2026-09-12 — Waves (boss id lock)

**Shipped**
- `chapter_01.json` bosses: 5:00 `rico_bloom`, 10:00 `railhorn`, 15:00 `mortar_host`.
- Minis at 3:00 and 8:00 → `railhorn_mini` (warn beats included).
- Elites remain `drifter_elite` / `tox_spout_elite` / `plated_drifter_elite`.

**Still data-only** per CoS (Milestone A).

## 2026-09-12 — Combat bot (Milestone A/B data pack, docs-first stop)

- **Files touched:** `data/weapons/*.json` (9), `data/passives/*.json` (8), `data/evolutions/*.json` (8), `data/enemies/*.json` (7), `data/bosses/*.json` (4: rico_bloom, railhorn, railhorn_mini, mortar_host), `data/statuses.json`, `docs/BALANCE.md`, this log. A-ship pair prioritized: `shard_knives`, `drifter`.
- **How to test:** `python3 -m json.tool` on each JSON; review `docs/BALANCE.md` id index + Waves→Combat mapping table. No Godot runtime yet from Combat.
- **Leftover risk:** Needs Godot resources / sprites, Systems damage pipeline + weapon behavior scripts, Arch folders. `COMBAT_ROSTER.md` not written (stopped per Lead steering). Waves must remapping chapter placeholders to Combat ids (table in BALANCE). Do not invent Habby names.

## 2026-09-12 — Systems — Milestone A kite loop

**Files touched:**
- `autoload/Pool.gd` — implemented `warm` (API unchanged: warm/acquire/release); acquire can instantiate from warmed scene on miss
- `scripts/player/Player.gd`, `FollowCamera.gd` + `scenes/player/Player.tscn` — drag-move, HP, magnet, temp auto-strike
- `scripts/meta/XpGem.gd`, `LevelUpUI.gd`, `RunHud.gd`, `TempSeeker.gd`
- `scenes/pickups/XpGem.tscn`, `scenes/ui/LevelUpUI.tscn`, `scenes/ui/RunHud.tscn`, `scenes/enemies_temp/TempSeeker.tscn`
- `scenes/run/Run.gd` + `Run.tscn` — spawn/pool wire, XP drop, level-up pause, death → hub

**How to test:** Godot 4.4 open `/workspace/horde-protocol` → F5 → Hub → Play. Drag to move; seekers chase; auto-strike kills → gems → magnet → level-up 3 cards pause. Die or Esc → Hub.

**Leftover risk:** `TempSeeker` + Player auto-strike are Systems stand-ins — Combat should replace with Drifter + Shard Knives. No real projectile VFX. Chapter SM / run save not in A. Level-up cards are dummy effects only.

**Handoff:** @Combat swap enemy/weapon; @Art HUD restyle; @QA cold-boot + pooling leak check when convenient.

**Combat sync:** TempSeeker is in groups `enemy` + `enemies`, exposes `take_damage` / `is_alive` for Shard Knives. Run is in group `run` for projectile parent. Auto-strike remains until `scenes/combat/ShardKnifeProjectile.tscn` + weapon mount land.

## 2026-09-12 — Combat — Milestone A (Shard Knives + Drifter)

**Shipped**
- `scripts/combat/CombatData.gd` — JSON loaders for weapons/enemies + level curve helper
- `scripts/combat/WeaponBase.gd` — auto-fire base; nearest target via group `"enemy"`
- `scripts/combat/ShardKnivesWeapon.gd` + `scenes/combat/ShardKnivesWeapon.tscn`
- `scripts/combat/ShardKnifeProjectile.gd` + `scenes/combat/ShardKnifeProjectile.tscn`
- `scripts/enemies/EnemyBase.gd` — `apply_damage`, pool acquire/release, `Events.enemy_killed`, XP via `run_root`
- `scripts/enemies/Drifter.gd` + `scenes/enemies/Drifter.tscn` — pool key `&"drifter"`, TempSeeker-compatible `activate(pos, player)`
- `scripts/combat/MILESTONE_A_HOOKS.md` — Systems swap instructions
- `docs/BALANCE.md` — starting numbers + id map + boss ids

**Systems hook (do this next)**
1. Attach `ShardKnivesWeapon.tscn` as child of player → `setup(player)`
2. `Pool.warm(&"drifter", Drifter.tscn, N)` and acquire `&"drifter"` instead of `temp_seeker`
3. Keep groups: player=`"player"`, enemy=`"enemy"`, run=`"run_root"`

**How to test:** After Systems swap, Boot→Hub→Play; knives auto-fire; Drifters seek + contact via Player hurtbox meta; kills emit `enemy_killed` + XP gem.

**Leftover risk:** No Habby art (Polygon2D placeholders). Projectile collision_mask=2 assumes enemy body layer 2. Boss/elite scenes not in A.

**Handoff:** @Systems — see `scripts/combat/MILESTONE_A_HOOKS.md`. @Art — replace Polygon2D with sprites when ready.

## 2026-09-12 — Combat — group sync

**Files touched:** `scripts/enemies/EnemyBase.gd`, `scripts/combat/WeaponBase.gd`, `scripts/combat/MILESTONE_A_HOOKS.md`

**Change:** Dual-tag enemies as `enemy` + `enemies`; Shard Knives nearest-target queries both (deduped). Unblocks Systems weapon mount.

**How to test:** Mount ShardKnivesWeapon; spawn Drifter/TempSeeker; confirm knives acquire targets.

**Leftover risk:** None for group lock.

## 2026-09-12 — Systems — Combat Milestone A wire-up

**Files touched:**
- `scenes/run/Run.gd` — Pool warm `&"drifter"`, spawn Drifter, attach `ShardKnivesWeapon` via `setup(player)`
- `scripts/player/Player.gd` — removed temp auto-strike (Combat weapon owns fire)

**How to test:** F5 → Hub → Play. Drag-move; Shard Knives auto-fire; Drifters seek + contact; gems → level-up; die/Esc → Hub.

**Leftover risk:** TempSeeker scenes left on disk unused. Level-up cards still dummy Systems effects (no weapon level bumps yet).

## 2026-09-12 — Art — Milestone A HUD + sprite bind

**Files touched:**
- `scenes/ui/RunHud.tscn`, `scripts/meta/RunHud.gd` — portrait chrome (chip, HP/XP bars, ink colors); bind API unchanged
- `scenes/ui/LevelUpUI.tscn` — card StyleBoxFlat (bible accent), larger touch targets
- `scenes/hub/Hub.tscn` — bg_deep + Play accent / Settings secondary
- `scenes/enemies/Drifter.tscn` + `scripts/enemies/Drifter.gd` — Sprite2D `walker_placeholder.png`; Visual typed as Node2D for Art swap
- `scenes/combat/ShardKnifeProjectile.tscn` — Sprite2D `shard_knife_placeholder.png`
- `assets/sprites/weapons/shard_knife_placeholder.png`

**How to test:** F5 → Hub (dark + blue PLAY) → Play. HUD bars under notch pad; level-up cards styled; Drifters/knives use placeholders.

**Leftover risk:** No SFX yet (Lead hold). Floor tile / VFX still default. RunHud.gd lightly edited for bar fills — Systems please yell if bind path drifts.

**Handoff:** @QA visual smoke on Hub→Play. @Systems API same (`bind_player`, `stop`).

## 2026-09-12 — QA — Milestone A static smoke

**Files touched:** `docs/KNOWN_ISSUES.md`, `docs/QA_CHECKLIST.md` (earlier), this log.

**How to test:** Open project in Godot 4.4 → Hub→Play → kite Drifters, level-up cards, die/Esc. No Godot on shared computer — static only this pass.

**Findings:** JSON pack OK; scene graph wired. Logged QA-A1 (multi-level one card), QA-A2 (paused→hub softlock risk), QA-A3 (group query watch). APK still NO-GO.

**Leftover risk:** Need editor or emulator runtime before calling A playable from QA.


## 2026-09-12 — Systems — QA-A1 / QA-A2 fixes

**Files touched:**
- `scripts/meta/LevelUpUI.gd` — queue multi-level cards; `force_close()` clears pause
- `scenes/run/Run.gd` — `PROCESS_MODE_ALWAYS`; Esc → `_abandon_to_hub` unpauses; death path ignore_pause timer

**How to test:** Level across 2+ levels on one gem → sequential card picks. Open level-up → Esc → Hub should not stay paused.

## 2026-09-12 — QA — recheck A1/A2

**Files touched:** `docs/KNOWN_ISSUES.md` (footnote + audit).

**How to test:** Still need Godot 4.4 Hub→Play.

**Notes:** Code-reviewed `2dd6d96` — queue + force_close/unpause look correct. A1/A2 stay Fixed pending runtime. A3 watch remains. APK NO-GO.

