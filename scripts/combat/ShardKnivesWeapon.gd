extends WeaponBase
class_name ShardKnivesWeapon
## Starter blade throw — auto-fires ShardKnifeProjectile at nearest enemy (group "enemy").

const DATA_ID := "shard_knives"
const PROJECTILE_SCENE := preload("res://scenes/combat/ShardKnifeProjectile.tscn")

var _data: Dictionary = {}
var _damage: float = 12.0
var _projectile_speed: float = 420.0
var _projectile_count: int = 1
var _pierce: int = 0


func _ready() -> void:
	_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		push_error("ShardKnivesWeapon: failed to load %s" % DATA_ID)
		return
	set_level(1)


func setup(p_owner: Node2D) -> void:
	super.setup(p_owner)
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	_apply_level_stats()


func set_level(p_level: int) -> void:
	level = maxi(1, p_level)
	_apply_level_stats()


func _apply_level_stats() -> void:
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		return
	var stats := CombatData.get_weapon_level_stats(_data, level)
	_damage = float(stats.get("damage", stats.get("base_damage", 12)))
	cooldown = float(stats.get("cooldown_s", 0.7))
	_projectile_speed = float(stats.get("projectile_speed", 420))
	_projectile_count = int(stats.get("projectile_count", 1))
	_pierce = int(stats.get("pierce", 0))


func _try_fire() -> bool:
	var target := find_nearest_enemy()
	if target == null:
		return false
	var origin := get_fire_origin()
	var base_dir := (target.global_position - origin).normalized()
	if base_dir.length_squared() < 0.001:
		base_dir = Vector2.RIGHT
	var count := maxi(1, _projectile_count)
	var spread := 0.18 if count > 1 else 0.0
	var start_angle := -spread * 0.5 * float(count - 1)
	for i in count:
		var dir := base_dir.rotated(start_angle + spread * float(i))
		_spawn_projectile(origin, dir)
	return true


func _spawn_projectile(origin: Vector2, direction: Vector2) -> void:
	var proj: Node = PROJECTILE_SCENE.instantiate()
	var host: Node = _projectile_parent()
	host.add_child(proj)
	if proj.has_method("launch"):
		proj.call("launch", origin, direction, _damage, _projectile_speed, _pierce, owner_node)
	elif proj is Node2D:
		(proj as Node2D).global_position = origin


func _projectile_parent() -> Node:
	var tree := get_tree()
	if tree:
		var run := tree.get_first_node_in_group("run_root")
		if run:
			var p := run.get_node_or_null("Projectiles")
			if p:
				return p
	if owner_node and owner_node.get_parent():
		return owner_node.get_parent()
	return self
