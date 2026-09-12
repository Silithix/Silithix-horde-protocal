# Export — Horde Protocol

Stub until Arch locks Godot version + Android export preset.

## Expected (fill when ready)
- Godot version:
- Export template version:
- Package: `com.hordeprotocol.survival`
- Min SDK: 24
- Target SDK: *(current stable)*
- ABIs: ARM64 required (`armeabi-v7a` optional)
- Orientation: sensor-portrait locked
- Output: `build/HordeProtocol-vX.Y.Z.apk`

## Local export (template)
```bash
godot --headless --export-release Android build/HordeProtocol.apk
```

## Keystore
- Project keystore for sideload OK for v1
- Passwords in gitignored `keystore.local` only
- Never commit production keystore passwords

## CI
- Goal: `.github/workflows/android-apk.yml` on tag `v*`
- If CI cannot hold templates/keystore: attach APK to GitHub Release manually; keep this doc accurate

## QA verify after every export
1. `adb install -r build/*.apk`
2. Cold boot checklist in `docs/QA_CHECKLIST.md`
3. Log fails in `docs/KNOWN_ISSUES.md`


## Arch note (2026-09-12)
`export_presets.cfg` present: Android, arm64-v8a, package `com.hordeprotocol.survival`, export path `build/HordeProtocol.apk`. Keystore fields empty — fill via `keystore.local` (gitignored) before release sign.
