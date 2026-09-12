# Horde Protocol — Art Bible

**Owner:** Art bot  
**Resolution:** 1080 × 1920 portrait · stretch `canvas_items` / aspect `expand`  
**Style lock:** Clean vector-ish shapes + soft pixel edge. One game, not a mashup. Original IP only — no Habby / Survivor.io assets or names.

---

## 1. Mood

Night-ops survival under neon threat. Cool dark ground, warm player, toxic melee, violet ranged, crimson elites. Readable first; pretty second.

---

## 2. Palette (hex)

| Token | Hex | Use |
|-------|-----|-----|
| `bg_deep` | `#0B0F1A` | Hub / title / card backs |
| `bg_floor` | `#141C2B` | Run map base |
| `bg_floor_alt` | `#1A2436` | Tile variation |
| `ink` | `#E8EEF8` | Primary text |
| `ink_dim` | `#8B97B0` | Secondary text |
| `player` | `#5CE1FF` | Rook / ally glow |
| `hp` | `#3DFF9A` | Health fill |
| `hp_low` | `#FF5C6C` | ≤30% HP |
| `xp` | `#7CFF5C` | XP bar + small gems |
| `xp_mid` | `#5CB8FF` | Blue gems |
| `xp_high` | `#FFD45C` | Gold gems / gold UI |
| `melee` | `#6B8F71` | Walkers / runners |
| `ranged` | `#B06BFF` | Spitters / projectiles |
| `elite` | `#FF3B4A` | Elite outline / aura |
| `boss` | `#FF8A3D` | Boss accent |
| `warn` | `#FFC53D` | Boss banner / telegraph |
| `card` | `#1E2A40` | Level-up card face |
| `card_stroke` | `#3A4F73` | Card border |
| `accent` | `#5C7CFF` | Buttons / focus |
| `danger` | `#FF4D6A` | Abandon / death |

**Rule:** Never put melee green and XP green at the same saturation on overlapping layers — XP is brighter neon; melee is desaturated.

---

## 3. Silhouette & size (design px @ 1080w)

| Role | Approx size | Read tip |
|------|-------------|----------|
| Player | 64–80 | Bright cyan rim; face movement dir |
| Walker | 56–72 | Rounded blob, grey-green |
| Runner | 48–64 | Elongated, lean forward |
| Spitter | 56–68 | Purple core + snout cue |
| Swarm fly | 28–36 | Tiny diamond / wing pair |
| Elite | base + 8–12 | Thick red outline (4px) |
| Boss | 160–220 | Unique silhouette each |
| XP gem | 16 / 22 / 28 / 34 | Color = value |
| Crate | 48–56 | Breakable prop, warm wood/metal |

Hit flash: white multiply 2–3 frames. Death: short scale-pop + fade (8–10 frames).

---

## 4. Portrait HUD (Milestone A target)

```
┌────────────────────────────────────┐
│ [chip] HP████████░░  ⏱ 02:34  ☠12 💰40 │
│ XP═════════════════════════════════ │
│                                    │
│              (playfield)           │
│                                    │
│         (joystick hint: first run) │
└────────────────────────────────────┘
```

- **Safe area:** pad ≥64px top / ≥48px bottom for notches (also respect Android insets when Arch wires export).
- **HP + portrait chip:** top-left. Bar height ≥24px.
- **Timer:** center-top, bold, high contrast.
- **Kills / gold:** top-right.
- **XP:** full-width strip under HP row (height ≥12px).
- **Touch targets:** ≥48dp (≈96px at 1080 design if density ~2; keep buttons ≥96×96 design px).
- **Joystick hint:** ghost ring bottom-center, first run only.
- **Reduce Motion:** no shake / no heavy pulse; keep hit flash.

### Level-up cards
Three large cards, center stack/row. Each: icon 96, name, 2-line effect, level pill. No skip in v1. Dim + pause world behind.

### Pause
Resume · Settings · Abandon (danger color).

### Results
Time · kills · gold · XP · weapons built · MVP weapon. Big Continue.

### Hub
Play (primary) · Characters · Equipment (stub ok) · Settings · Credits.

---

## 5. Typography

- UI: one sans (Godot default or bundled OFL font — log in CREDITS).
- Title / boss banner: heavier weight, ALL CAPS ok for WARN only.
- Body on cards: ≤2 lines, ~28–32px design.
- Never put critical text under 24px design height.

---

## 6. Placeholder policy

Allowed for Milestone A–B **only if**:
1. Same palette as this bible  
2. High contrast on `bg_floor`  
3. Consistent shape language (rounded rects / simple polygons)  
4. Named for replacement (`player_rook_placeholder.svg` → `player_rook.png`)

Replace with coherent pack before Milestone D APK.

---

## 7. Audio (royalty-free only)

| Cue | Feel | Notes |
|-----|------|-------|
| Music loop | Dark pulse, 90–110 BPM, no vocal | One loop, crossfade |
| Hit | Short tick / thunk | Pitch vary ±10% |
| Level-up | Bright chime | Distinct from chest |
| Chest | Metallic open | |
| Boss warn | Alarm sting | With banner |
| Pickup | Soft blip by type | |
| Death | Downward swell | Short |

Document every file in root `CREDITS.md` (source, license, URL). No paid packs. No Habby audio.

`Audio.gd` (Arch/Systems) should expose bus: Master / Music / SFX; honor settings mute + haptic flag (haptic is Systems).

---

## 8. VFX hooks Combat/Systems can call

- `hit_flash` on hurtbox
- `death_pop` on kill
- `xp_spark` on gem collect
- `screen_shake(intensity)` — gated by Reduce Motion
- `boss_banner`
- `evo_burst` on evolution

Art owns particles/sprites; Systems owns when they fire.

---

## 9. Milestone A art checklist

- [x] Art bible locked
- [ ] Placeholder player (cyan)
- [ ] Placeholder walker (melee green)
- [ ] Placeholder gem (xp green)
- [ ] HUD chrome (HP/XP/timer slots)
- [ ] 3 dummy level-up cards styled
- [ ] Hit flash + death pop
- [ ] CREDITS.md stub + any temp SFX sources listed

---

## 10. Out of scope for Art

`project.godot`, gameplay scripts, weapon numbers, chapter JSON, APK export — other bots. Art never overwrites their files; coordinate via Chief of Staff + `docs/BOT_LOG.md`.
