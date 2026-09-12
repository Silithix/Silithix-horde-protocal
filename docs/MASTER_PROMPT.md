# MASTER PROMPT — Give this entire document to Grok Bot

You are Grok Bot acting as **engineering lead + multi-agent orchestrator** for a complete, shippable Android game.

Your job is to **design, implement, test, version, and export** a portrait-mode top-down auto-shooter wave-survival game that plays like **Survivor.io** (Habby / Gorilla Game Studio) — NOT Surviv.io the battle royale.

Final deliverable: a **public or private GitHub repo** with a clean commit history, plus a **sideloadable release APK** (`app-release.apk` or signed debug APK if a release keystore is not available). The APK must install on a modern Android phone and run the full core loop offline.

Do not stop at a design doc. Do not stop at a prototype that only works in the editor. Ship playable software.

---

## 0. How you will work (mandatory multi-bot process)

Spin up **at least these 7 specialized bots**. You may add more if a gap appears. Each bot has a single job, a Definition of Done, and must leave artifacts in the repo. You (Lead Bot) assign work, resolve conflicts, merge, and never let two bots own the same file at the same time.

### Bot 1 — Lead / Producer (`lead`)
**Job:** Own the product. Break work into issues/PRs. Keep scope honest. Decide cut-vs-keep. Write the README, roadmap, and release notes. Block feature creep. Require playable increments every milestone.
**Owns:** `README.md`, `docs/`, GitHub Issues/PR descriptions, milestone plan, final go/no-go on APK.
**Does not:** write core gameplay systems unless a specialist is blocked.

### Bot 2 — Engine / Architecture (`arch`)
**Job:** Choose and lock the stack. Create the Godot 4 project skeleton, folder conventions, autoloads, signal bus, save path, scene tree, and export presets. Make the game boot to a title screen on first run.
**Owns:** `project.godot`, `addons/` decisions, `autoload/`, `scenes/boot/`, Android export preset, `.gitignore`, CI workflow skeleton.
**Stack lock (do not reopen unless blocked):**
- Engine: **Godot 4.3+** (4.4 preferred if export templates exist)
- Language: **GDScript** only for gameplay (no C# for this project — Android export and LLM reliability)
- Render: 2D, Mobile renderer
- Orientation: **Portrait**, design resolution **1080 × 1920**, stretch mode `canvas_items`, aspect `expand`
- Input: full-screen drag-to-move (Survivor.io style) + optional on-screen joystick toggle in settings
- Physics: Godot 2D physics for player/enemy overlap; projectiles may use area checks or a custom spatial hash if counts get high
- Data: JSON + custom Resources (`.tres`) for weapons, enemies, waves, characters
- Persistence: `user://save.json` for meta unlocks / settings / last run stats
- No paid assets. No Unity. No ads, IAP, gacha, energy, or online accounts in v1.

### Bot 3 — Gameplay Systems Programmer (`systems`)
**Job:** Implement the Survivor.io core loop as systems, not one-off scripts.
**Owns:** player controller, camera, XP/level-up, pickup magnet, health/damage pipeline, pause, run timer, chapter state machine, object pooling, spatial partitioning / enemy cap, save/load of a run.
**Definition of Done for systems:**
- Player moves with one finger; character faces movement direction
- All weapons fire **automatically** on cooldown with their own targeting rules
- Enemies spawn off-screen, seek the player, deal contact damage (plus typed attacks for elites/bosses)
- Kills drop XP gems (green small / green large / blue / gold)
- XP vacuum radius exists and can be upgraded
- Level-up **pauses the run**, shows 3 cards, player must pick one, then resume
- Hard caps: 6 weapons + 6 passives. Duplicate picks upgrade that card. When both lists are full and maxed, extra levels grant gold or heal
- Chapter timer at top. Events fire on a timeline, not “random forever”
- Death → results screen → hub. Survive to chapter time limit → victory chest + results
- 60 FPS target on a mid-range Android phone with ≥200 alive enemies via pooling + sprite batching + cheap shadows

### Bot 4 — Combat Content (`combat`)
**Job:** Design AND implement weapons, passives, evolutions, enemies, elites, bosses, and status effects so they *feel* like Survivor.io, not generic bullets.
**Owns:** `data/weapons/`, `data/passives/`, `data/evolutions/`, `data/enemies/`, `data/bosses/`, projectile scenes, hit VFX hooks.
**Minimum content for v1 ship (do not ship with less):**

**Weapons (8 base, each with 5 upgrade levels):**
1. **Kunai** — homing-ish thrown knives at nearest enemy. Fast, single-target. Evo with Ninja Scroll → **Spirit Shuriken** (more knives, pierce, orbit-return).
2. **Forcefield** — damaging ring around the player. Evo with Energy Drink → **Energy Wave / Defender** (larger ring + periodic pulse heal-on-kill feel).
3. **Guardian** — 1–3 orbiting saws around the player. Evo with Exo-Bracer → **Defender Orbits** (more satellites, knockback).
4. **Lightning Emitter** — random-area bolts. Evo with Energy Cube → **Supercell** (chain + storm cloud).
5. **Boomerang** — outbound + return arc. Evo with Hi-Power Magnet → **Magnetic Rebounder**.
6. **Molotov** — ground fire pools. Evo with Oil Bond → **Inferno**.
7. **Drill Shot** — piercing linear shot. Evo with Fitness Guide or equivalent pierce passive → **Whistling Arrow**.
8. **Drone Pair (Type A + Type B as two weapon cards)** — auto turrets that float near the player and fire independently. Both together can evo into a dual-drone barrage.

**Passives (8):**
- Sports Shoes (move speed)
- Energy Drink (cooldown reduction + HP regen)
- Exo-Bracer (attack size / area)
- Hi-Power Magnet (pickup radius)
- Energy Cube (element / tech weapon power)
- Fitness Guide (melee / projectile damage)
- Ninja Scroll (projectile count / kunai family)
- Oil Bond (burn duration / fire weapons)

**Evolution rule (exact Survivor.io feel):**
Weapon must be **level 5**. Required passive must be owned (any level). Next **gold/boss chest** offers the evolution (or auto-applies if you want simpler v1 — pick one and document it). Evolved weapon replaces the base card and keeps scaling.

**Enemies for Chapter 1:**
- Walker (slow melee, contact damage)
- Runner / dog (fast melee)
- Spitter (ranged purple shot)
- Armored walker (high HP, slow)
- Swarm fly (small, diagonal drift, dies fast)
- Elite versions of walker/spitter with red aura, more HP, chest drop
- Mini-boss at ~3:00 and ~8:00
- Boss at 5:00, 10:00, 15:00

**Boss minimum (3 unique patterns, not just big walkers):**
1. **Bouncebloom-style** — fires bouncing orbs in bursts; telegraph, then volley. Weak to kiting.
2. **Charger** — wind-up line charge + shockwave on slam. Arena clamp optional.
3. **Summoner / artillery** — stays mid-range, drops poison puddles or mortar circles, summons a pack at 66% and 33% HP.

Boss intro: clear or freeze trash for a beat, banner “WARNING / BOSS”, camera punch, then fight. Killing a boss drops a **gold chest**. Chest UI: tap to open, 1 reward (weapon upgrade, passive upgrade, or evolution if eligible). Rare 3-item chest later if time.

**Status effects:** burn, slow, knockback, freeze (short). Keep them data-driven.

### Bot 5 — Stage / Wave / Feel Designer (`waves`)
**Job:** Make Chapter 1 a 15-minute authored experience, not a raw spawn-rate slider.
**Owns:** `data/chapters/chapter_01.json`, crate table, horde formations, difficulty curve, pickup table.
**Chapter 1 timeline (adapt numbers, keep the *shape*):**
- 0:00 — light walkers, teach movement + first kunai
- 1:00 — first spitters
- 1:30 — runners replace some walkers
- 2:00–2:30 — **horde** (ring or lane dump)
- 3:00 — armored elite + cross-formation spitters
- 4:00 — dog horde
- 5:00 — **Boss 1**. After boss, armored walkers become common
- 6:00 — surround circle + diagonal flies
- 7:30 — mixed pressure
- 8:00 — mini-boss + chest
- 9:00 — dense mixed horde
- 10:00 — **Boss 2** (harder pattern, maybe arena ring)
- 11:00–13:30 — escalating density, elites more often
- 14:00 — pre-final horde
- 15:00 — **Boss 3 / chapter clear**

Also place **breakable crates** on the looping map: heal meat, bomb (screen nuke / large circle), magnet (vacuum all XP), gold bag, rare weapon chest.

Map: **infinite-feeling tiled city/graveyard/lab floor** that repeats. Camera follows player. Soft collision with props optional; do not trap the player.

Win: survive 15:00 and kill final boss (or survive the timer if final boss is skipped by death-rule — prefer kill required).
Lose: HP hits 0. Offer one optional “watch ad to revive” **stub only** (button that says Coming Soon / disabled). No real ads.

### Bot 6 — Art / UI / Audio (`art`)
**Job:** Make it readable at phone size and satisfying, even if stylized-simple. Placeholder programmer-art is allowed **only** if it is consistent, high-contrast, and replaced with a coherent pixel or clean-vector pack before APK.
**Owns:** `assets/`, theme, HUD, menus, SFX, music loop.
**Visual rules:**
- Portrait HUD: HP bar + portrait chip top-left, XP bar full width under it or top edge, timer center-top, kill/gold counters top-right, joystick hint only on first run
- Level-up cards: large, tappable, icon + name + 2-line effect + current level. Three cards. No skip in v1
- Pause: resume / settings / abandon run
- Results: time survived, kills, gold, XP, weapons built, MVP weapon
- Hub: Play, Characters (2–3), Equipment (stub or simple stat sticks), Settings, Credits
- Enemy readability: silhouette + color coded (melee grey-green, ranged purple, elite red outline, boss unique)
- Damage numbers (optional toggle), hit flash, death pop, XP gem color by value
- Screen shake on boss slam / evolution, but respect Reduce Motion
- Audio: one music loop, SFX for hit, level-up, chest, boss warn, pickup, death. Royalty-free only (document sources in `CREDITS.md`)

Generate or assemble a **single art bible** so a kunai, a walker, and a button look like one game.

### Bot 7 — QA / Performance / Release (`qa`)
**Job:** Break the game, then make the APK real.
**Owns:** `tests/` (GdUnit or scripted headless smoke), `tools/`, `.github/workflows/`, `export/` notes, device checklist, known-issues list.
**Must verify:**
- Fresh install → title → hub → run → die/win → hub, no crash
- Level-up cannot softlock
- Evolution actually replaces the weapon
- 10+ minute run does not leak nodes or freeze
- Touch targets ≥ 48dp
- Back button pauses
- App survives Android backgrounding
- APK installs on ARM64
- First-run permissions: none beyond what Godot needs (no contacts, no location)
- Repo builds from a clean clone via documented commands

---

## 1. Product definition (what “clone of Survivor.io” means here)

This is a **survivors-like / reverse bullet hell**:

- You only steer.
- The character dumps damage automatically.
- The map fills with trash mobs that are individually weak and collectively lethal.
- Power fantasy comes from **build-making**: pick 3-of-N cards every level until your loadout is a machine.
- Pressure is **authored by a clock**, punctuated by elites, hordes, and scripted bosses.
- After the run, a light **meta layer** makes the next run start slightly stronger.

Feel targets (playtest against these, not against a feature list):
1. First 30 seconds: “I am weak, I must kite.”
2. First evolution (~4–7 min if playing well): “I just became a blender.”
3. Minute 10: “If I stand still I die; if I path well I delete the screen.”
4. Bosses are **readable exams**, not HP sponges with the same AI as walkers.
5. Death feels like “my build was wrong or I greed-tanked,” not “hitboxes are lies.”

Legal / ethics: original title, original characters, original art. Inspired by Survivor.io and Vampire Survivors. Do **not** copy Habby art, names, logos, maps, or audio. Use a new name.

**Working title:** `HORDE PROTOCOL`  
Package: `com.hordeprotocol.survival`  
Display name: `Horde Protocol`

Rename if the lead finds a better original name. Keep it original.

---

## 2. Scope — what ships in v1 APK vs what is explicitly cut

### Ships in v1 (required)
- Title, hub, settings (music/sfx/haptic/joystick style/reduce motion)
- 1 playable character fully tuned + 2 locked characters shown in hub (unlock with gold from runs)
- 1 full 15-minute chapter with 3 bosses
- 8 weapons, 8 passives, at least 6 working evolutions
- XP / level-up / 6+6 loadout cap
- Crates + 4 pickup types
- Gold earned in-run, spent in hub on:
  - character unlocks
  - 8 cheap permanent stat nodes (HP, ATK, SPD, pickup, starting weapon level, gold find, etc.)
- Results screen + simple best-time / kill record per chapter
- Pause, death, victory
- Android portrait APK, offline, no account

### Explicitly cut from v1 (do not implement unless v1 is already fun and shipped)
- Gacha, energy, ads, IAP, daily login, chat, PvP, seasons
- 10 chapters, open world, multiplayer
- Full equipment inventory with rarity crafting (a slim stat-stick version is enough)
- Talent trees per character beyond 1 unique starting weapon + 1 passive trait
- Cloud save
- iOS
- English-only is fine

If a bot wants to add cut content, they open an issue labeled `v2` and move on.

---

## 3. Characters (v1)

Each character is a data file: starting weapon, trait, base stats.

1. **Rook (starter, unlocked)**  
   Trait: +10% pickup radius. Starts with Kunai. Balanced HP/speed.  
   Fantasy: default survivor, teaches the game.

2. **Warden (unlock ~300 gold)**  
   Trait: starts with Forcefield; +15% max HP; -8% move speed.  
   Fantasy: stand-your-ground tank who still has to kite bosses.

3. **Spark (unlock ~600 gold)**  
   Trait: starts with Lightning Emitter; +10% cooldown; -10% max HP.  
   Fantasy: glass artillery.

Do not add more characters until these three are distinct in a blind playtest.

---

## 4. Technical architecture (non-negotiable patterns)

```
horde-protocol/
  project.godot
  README.md
  CREDITS.md
  docs/
    DESIGN.md
    BOT_LOG.md          # each bot appends what they shipped
    BALANCE.md
    EXPORT.md
  autoload/
    Game.gd             # run state
    Events.gd           # signal bus
    Save.gd
    Audio.gd
    Pool.gd
  scenes/
    boot/Boot.tscn
    hub/Hub.tscn
    run/Run.tscn
    ui/...
  scripts/
    player/
    combat/
    enemies/
    waves/
    picks/
    meta/
  data/
    weapons/*.tres or *.json
    passives/
    enemies/
    chapters/
    characters/
  assets/
    sprites/
    ui/
    sfx/
    music/
  tests/
  .github/workflows/android-apk.yml
```

**Patterns the systems bot must use:**
- Object pool for enemies, gems, projectiles, damage numbers. Never `queue_free` hot objects every frame.
- Weapons are data + a small behavior script (strategy / component), not a 2,000-line Player.gd.
- Enemies: shared `Enemy.gd` + behavior resource (seek, shoot, charge, orbit).
- Wave director reads chapter JSON: `{ t, action, enemy, count, formation, hp_mult }`.
- Formations: scatter, ring, cross, line, flood-from-edge.
- Damage pipeline: `Hurtbox.receive(HitInfo)` so armor, i-frames, and statuses stay in one place.
- Player i-frames: brief after hit so overlapping 40 walkers don’t delete you in one frame. Contact damage ticks (~0.4s), not per-physics-frame.
- Deterministic-enough RNG with a run seed stored for bug reports.
- Debug overlay (hidden in release): enemy count, draw calls, FPS, current wave id, give-XP / spawn-boss / godmode cheats behind a 5-tap version number.

**Performance budget:**
- Cap live enemies (e.g. 250). Extra intended spawns wait in a queue.
- Cap live gems (merge nearby gems into higher-value orbs if the floor is littered).
- No per-frame `get_tree().get_nodes_in_group` in _process.
- Use `PhysicsDirectSpaceState2D` or a cheap grid for “nearest enemy” queries.
- Sprite frames small; atlas packed.

---

## 5. GitHub standard of work

1. Create repo `horde-protocol` (or the final name).
2. `main` is always bootable.
3. Branch per bot or per milestone: `feat/player-move`, `feat/weapons-kunai`, `feat/chapter1-timeline`, `chore/android-export`.
4. Commit messages: conventional (`feat:`, `fix:`, `balance:`, `art:`, `build:`).
5. Every milestone PR updates `docs/BOT_LOG.md` with: bot name, files touched, how to test, leftover risk.
6. Tag `v0.1.0-playable`, `v0.2.0-chapter`, `v1.0.0-apk`.
7. GitHub Actions: on tag `v*`, export Android APK artifact. If CI cannot hold Godot export templates + keystore, document a one-command local export in `docs/EXPORT.md` and still attach the APK to the GitHub Release.

**Android export requirements:**
- Godot Android export template matching the engine version
- Package `com.hordeprotocol.survival`
- Min SDK 24, target SDK current stable
- ARM64 (armeabi-v7a optional)
- Orientation sensor-portrait locked
- Immersive / edge-to-edge safe area padding for notches
- App icon + adaptive icon + splash that is not the default Godot robot
- Signed APK. If no release keystore exists, generate a project keystore, store passwords in a local unscanned file `keystore.local` (gitignored), and document how the human replaces it. Never commit a real production keystore password in plain text on a public repo.

---

## 6. Milestone plan (Lead Bot enforces this order)

Do not start chapter 3 content before milestone A is fun.

### Milestone A — “I can kite and shoot” (day 1 target)
Boot → hub → run. Player moves. One weapon auto-fires. One enemy type seeks and deals tick damage. Gems drop and level the player. Level-up UI with 3 dummy cards that increase damage or speed. Death works. Editor run is already portrait.

### Milestone B — “It is a survivors-like”
All 8 weapons at level 1 behavior. 4 enemy types. XP tiers. Pickup magnet. Crates. Pause. HUD polished enough to screenshot. 2-minute authored opener.

### Milestone C — “Chapter 1 exists”
Full 15-min timeline, 3 bosses, elites, chests, 6+ evolutions, 3 characters (1 unlocked). Meta gold + 8 hub upgrades. Results screen.

### Milestone D — “Phone”
Android export preset, icons, notch padding, performance pass on a 200-enemy stress script, settings, credits, first APK installed and launched on a device or emulator.

### Milestone E — “Give it to the human”
GitHub Release `v1.0.0` with:
- `HordeProtocol-v1.0.0.apk`
- source zip / repo link
- known issues
- how to install (enable unknown sources)
- how to rebuild

After E, only bugfixes and balance.

---

## 7. Balance starting numbers (combat bot may retune, must log changes)

Player Rook: 100 HP, 180 px/s, 0 armor, 1.0s hit tick, 0.3s i-frame.
Kunai L1: 12 dmg, 0.7s cooldown, 1 knife, 420 px/s, nearest enemy.
Walker: 18 HP, 70 px/s, 8 contact dmg/tick.
Runner: 12 HP, 130 px/s, 8 dmg.
Spitter: 16 HP, 55 px/s, 10 projectile dmg, 1.6s fire, telegraph 0.25s.
Elite: ×6 HP, ×1.4 dmg, chest.
Boss 1: ~800 HP (scale after playtest), 2-phase optional.
XP to level: 5, 10, 16, 24, 34… mild exponential, so a good player hits level 8–12 by boss 1 and 20+ by minute 15.
Gold: 1 per small kill, more for elites, chest bonus. Hub upgrades cost 50 / 80 / 120…

If the player can AFK minute 8 and live, spawn rate is too low or damage is too high.
If a new player dies before 1:30 with no mistakes besides standing still, that is acceptable. If they die while kiting cleanly before 1:30, player HP or enemy speed is wrong.

---

## 8. QA script the QA bot must run before calling APK done

1. Cold boot to hub under 4 seconds on emulator.
2. Start run, move in a circle for 20 seconds, never take damage from a single walker if kiting — weapons should kill them.
3. Collect enough XP to level 3. Confirm pause-the-world card pick. Confirm picking the same weapon twice upgrades it.
4. Force a boss with cheat. Confirm banner, pattern, chest, unpause.
5. Fill 6 weapons. Confirm no 7th weapon offered (only passives/gold/heal).
6. Trigger an evolution. Confirm base weapon gone, evo present, attacks changed.
7. Die. Results. Hub. Gold persisted after kill-app-reopen.
8. Win chapter (or cheat to 15:00). Victory state, not a freeze.
9. 12-minute soak: FPS ≥ 50 on emulator with quality medium, enemy cap hit, no orphan nodes climbing.
10. Install APK over a previous build. No data wipe unless version migration is documented.

Log failures in `docs/KNOWN_ISSUES.md`. Fix blockers. Ship with at most minor issues.

---

## 9. What you will hand the human when you are done

1. GitHub repo URL
2. Release page with the APK
3. `README.md` that a tired person can follow:
   - what the game is
   - controls
   - how to install the APK
   - how to open in Godot
   - how to export themselves
4. Short video or GIF in `/docs` or README of a 20-second run (optional but high value)
5. Honest list of what is prototype vs finished

If GitHub upload or APK signing cannot be completed in your environment, still produce:
- a complete Godot project that opens and runs
- `docs/EXPORT.md` with exact Godot version, export template version, keystore steps, and `godot --headless --export-release Android path/to.apk`
- the APK file in `build/` if the environment can emit it

Do not declare victory with only source and no export path.

---

## 10. Lead Bot standing orders

- Prefer a finished Chapter 1 over five half-systems.
- If two bots disagree, choose the option that is more readable on a phone and cheaper to run.
- Name things like a shipped game, not like a tutorial (`Player.tscn`, not `test2_final_REAL.tscn`).
- Every session ends with a playable `main`.
- Write comments only where the next bot would guess wrong.
- When you copy a mechanic from Survivor.io, rewrite it in original numbers, names, and art.
- Start now. Create the repo structure, lock Godot version in README, and implement Milestone A before any more design prose.

Begin.
