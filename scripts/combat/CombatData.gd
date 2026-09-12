extends RefCounted
class_name CombatData
## Static JSON loaders for Combat-owned data (weapons / enemies).

const WEAPONS_DIR := "res://data/weapons/"
const ENEMIES_DIR := "res://data/enemies/"


static func load_weapon(id: String) -> Dictionary:
	return _load_json(WEAPONS_DIR.path_join(id + ".json"))


static func load_enemy(id: String) -> Dictionary:
	return _load_json(ENEMIES_DIR.path_join(id + ".json"))


## Returns the level_curve entry for `level`, merged over base weapon fields.
static func get_weapon_level_stats(weapon_data: Dictionary, level: int) -> Dictionary:
	var stats := weapon_data.duplicate(true)
	var curve: Array = weapon_data.get("level_curve", [])
	var best: Dictionary = {}
	for entry in curve:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var lv: int = int(entry.get("level", 0))
		if lv <= level and lv >= int(best.get("level", 0)):
			best = entry
	for k in best.keys():
		if k == "level":
			continue
		stats[k] = best[k]
	# Normalize common keys from base if curve omitted them.
	if not stats.has("damage"):
		stats["damage"] = stats.get("base_damage", 0)
	return stats


static func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("CombatData: missing file %s" % path)
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("CombatData: cannot open %s" % path)
		return {}
	var text := f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("CombatData: invalid JSON object at %s" % path)
		return {}
	return parsed as Dictionary
