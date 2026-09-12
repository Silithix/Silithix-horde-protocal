extends Node
## Meta persistence: unlocks, settings, last-run stats.
## Path locked: user://save.json

const SAVE_PATH := "user://save.json"

var data: Dictionary = {}

func _ready() -> void:
	load_game()

func default_data() -> Dictionary:
	return {
		"version": 1,
		"settings": {
			"music": true,
			"sfx": true,
			"haptic": true,
			"joystick": false,
			"reduce_motion": false,
		},
		"meta": {
			"gold": 0,
			"unlocked_characters": ["rook"],
			"hub_upgrades": {},
			"best": {},
		},
		"last_run": {},
	}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func load_game() -> void:
	if not has_save():
		data = default_data()
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		data = default_data()
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		data = default_data()
		return
	data = parsed
	_migrate()

func save_game() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		push_error("Save: cannot write %s" % SAVE_PATH)
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func clear_save() -> void:
	data = default_data()
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)
	save_game()

func _migrate() -> void:
	var base := default_data()
	for k in base.keys():
		if not data.has(k):
			data[k] = base[k]
