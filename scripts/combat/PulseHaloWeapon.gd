extends WeaponBase
class_name PulseHaloWeapon
## Self-aura damaging ring around owner. Reads pulse_halo.json. Tick via apply_damage.

const DATA_ID := "pulse_halo"
const BASE_RADIUS_PX := 96.0
const RING_COLOR := Color(0.36, 0.88, 1.0, 0.22)
const RING_PULSE_COLOR := Color(0.55, 0.95, 1.0, 0.55)

var _data: Dictionary = {}
var _damage: float = 8.0
var _area_scale: float = 1.0
var _knockback: float = 20.0
var _radius: float = BASE_RADIUS_PX
var _pulse_left: float = 0.0


func _ready() -> void:
	z_index = -1
	_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		push_error("PulseHaloWeapon: failed to load %s" % DATA_ID)
	set_level(1)
	queue_redraw()


func setup(p_owner: Node2D) -> void:
	super.setup(p_owner)
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	_apply_level_stats()
	if owner_node and is_instance_valid(owner_node):
		global_position = owner_node.global_position
	queue_redraw()


func set_level(p_level: int) -> void:
	level = maxi(1, p_level)
	_apply_level_stats()


func _apply_level_stats() -> void:
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		return
	var stats := CombatData.get_weapon_level_stats(_data, level)
	_damage = float(stats.get("damage", stats.get("base_damage", 8)))
	cooldown = float(stats.get("cooldown_s", 0.45))
	_area_scale = float(stats.get("area_scale", 1.0))
	_knockback = float(stats.get("knockback", 20))
	_radius = BASE_RADIUS_PX * _area_scale
	queue_redraw()


func _process(delta: float) -> void:
	if owner_node and is_instance_valid(owner_node):
		global_position = owner_node.global_position
	if _pulse_left > 0.0:
		_pulse_left = maxf(0.0, _pulse_left - delta)
		queue_redraw()
	super._process(delta)


func _try_fire() -> bool:
	_damage_in_radius()
	_pulse_left = 0.12
	queue_redraw()
	return true


func _damage_in_radius() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var origin := get_fire_origin()
	var r2: float = _radius * _radius
	var seen: Dictionary = {}
	for group_name in ["enemy", "enemies"]:
		for node in tree.get_nodes_in_group(group_name):
			if seen.has(node):
				continue
			seen[node] = true
			if not is_instance_valid(node) or not (node is Node2D):
				continue
			if node == owner_node:
				continue
			var enemy := node as Node2D
			if enemy.has_method("is_alive") and not bool(enemy.call("is_alive")):
				continue
			if origin.distance_squared_to(enemy.global_position) > r2:
				continue
			if enemy.has_method("apply_damage"):
				enemy.call("apply_damage", _damage, owner_node if owner_node else self)
			elif enemy.has_method("take_damage"):
				enemy.call("take_damage", _damage, owner_node if owner_node else self)
			if enemy is CharacterBody2D and _knockback > 0.0:
				var away := enemy.global_position - origin
				if away.length_squared() > 0.01:
					(enemy as CharacterBody2D).velocity += away.normalized() * (_knockback * 10.0)


func _draw() -> void:
	var pulsing := _pulse_left > 0.0
	var fill := RING_PULSE_COLOR if pulsing else RING_COLOR
	var stroke := Color(0.36, 0.88, 1.0, 0.85 if pulsing else 0.55)
	draw_circle(Vector2.ZERO, _radius, fill)
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 56, stroke, 4.0 if pulsing else 3.0)
	draw_arc(Vector2.ZERO, maxf(8.0, _radius * 0.72), 0.0, TAU, 40, Color(0.36, 0.88, 1.0, 0.18), 1.5)
