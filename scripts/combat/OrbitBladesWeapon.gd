extends WeaponBase
class_name OrbitBladesWeapon
## 1–3 damaging blades on a fixed orbit around owner. Reads orbit_blades.json.
## Cooldown unused — continuous contact with a short per-target ICD.

const DATA_ID := "orbit_blades"
const HIT_INTERVAL_S := 0.22
const BLADE_HIT_RADIUS := 16.0
const BLADE_COLOR := Color(0.78, 0.84, 0.95, 0.95)
const BLADE_EDGE := Color(0.45, 0.55, 0.72, 1.0)

var _data: Dictionary = {}
var _damage: float = 10.0
var _blade_count: int = 1
var _orbit_radius: float = 90.0
var _orbit_speed_deg: float = 180.0
var _knockback: float = 60.0
var _angle: float = 0.0
var _blades: Array[Area2D] = []
## instance_id -> seconds remaining before that enemy can be hit again
var _hit_cooldown: Dictionary = {}


func _ready() -> void:
	_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		push_error("OrbitBladesWeapon: failed to load %s" % DATA_ID)
	set_level(1)
	_rebuild_blades()


func setup(p_owner: Node2D) -> void:
	super.setup(p_owner)
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	_apply_level_stats()
	_rebuild_blades()
	if owner_node and is_instance_valid(owner_node):
		global_position = owner_node.global_position


func set_level(p_level: int) -> void:
	level = maxi(1, p_level)
	_apply_level_stats()
	_rebuild_blades()


func _apply_level_stats() -> void:
	if _data.is_empty():
		_data = CombatData.load_weapon(DATA_ID)
	if _data.is_empty():
		return
	var stats := CombatData.get_weapon_level_stats(_data, level)
	_damage = float(stats.get("damage", stats.get("base_damage", 10)))
	# JSON cooldown_s is 0 — orbit is continuous; keep WeaponBase from spamming _try_fire.
	cooldown = 9999.0
	_blade_count = clampi(int(stats.get("projectile_count", 1)), 1, 3)
	_orbit_radius = float(stats.get("orbit_radius_px", 90))
	_orbit_speed_deg = float(stats.get("projectile_speed", 180))
	_knockback = float(stats.get("knockback", 60))


func _try_fire() -> bool:
	# Orbit blades do not pulse-fire; damage is continuous contact.
	return false


func _process(delta: float) -> void:
	if owner_node and is_instance_valid(owner_node):
		global_position = owner_node.global_position
	_angle = fmod(_angle + deg_to_rad(_orbit_speed_deg) * delta, TAU)
	_place_blades()
	_tick_hit_cooldowns(delta)
	_damage_overlaps()
	# Skip WeaponBase auto-fire (cooldown unused for this weapon).
	# Still allow base early-out when owner missing:
	if owner_node == null or not is_instance_valid(owner_node):
		return


func _rebuild_blades() -> void:
	for b in _blades:
		if is_instance_valid(b):
			b.queue_free()
	_blades.clear()
	for i in _blade_count:
		var blade := _make_blade(i)
		add_child(blade)
		_blades.append(blade)
	_place_blades()


func _make_blade(index: int) -> Area2D:
	var blade := Area2D.new()
	blade.name = "Blade_%d" % index
	blade.monitoring = true
	blade.monitorable = false
	blade.collision_layer = 0
	blade.collision_mask = 2 # enemy body layer
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = BLADE_HIT_RADIUS
	shape.shape = circle
	blade.add_child(shape)
	var spr := Sprite2D.new()
	spr.name = "Visual"
	spr.scale = Vector2(0.55, 0.55)
	var tex := load("res://assets/sprites/weapons/orbit_blade_placeholder.png")
	if tex:
		spr.texture = tex
	else:
		# Fallback diamond if Art asset missing
		var poly := Polygon2D.new()
		poly.name = "VisualPoly"
		poly.color = BLADE_COLOR
		poly.polygon = PackedVector2Array([
			Vector2(0, -14),
			Vector2(10, 0),
			Vector2(0, 14),
			Vector2(-10, 0),
		])
		blade.add_child(poly)
		return blade
	blade.add_child(spr)
	return blade


func _place_blades() -> void:
	var n := _blades.size()
	if n <= 0:
		return
	for i in n:
		var blade: Area2D = _blades[i]
		if not is_instance_valid(blade):
			continue
		var a: float = _angle + TAU * float(i) / float(n)
		blade.position = Vector2(cos(a), sin(a)) * _orbit_radius
		blade.rotation = a + PI * 0.5


func _tick_hit_cooldowns(delta: float) -> void:
	var dead: Array = []
	for id in _hit_cooldown.keys():
		var left: float = float(_hit_cooldown[id]) - delta
		if left <= 0.0:
			dead.append(id)
		else:
			_hit_cooldown[id] = left
	for id in dead:
		_hit_cooldown.erase(id)


func _damage_overlaps() -> void:
	var source: Node = owner_node if owner_node else self
	var seen: Dictionary = {}
	for blade in _blades:
		if not is_instance_valid(blade):
			continue
		for body in blade.get_overlapping_bodies():
			_try_hit_node(body, source, seen)
		for area in blade.get_overlapping_areas():
			_try_hit_node(area, source, seen)


func _try_hit_node(node: Node, source: Node, seen: Dictionary) -> void:
	var enemy := _resolve_enemy(node)
	if enemy == null or seen.has(enemy):
		return
	seen[enemy] = true
	if enemy.has_method("is_alive") and not bool(enemy.call("is_alive")):
		return
	var id := enemy.get_instance_id()
	if _hit_cooldown.has(id):
		return
	_hit_cooldown[id] = HIT_INTERVAL_S
	if enemy.has_method("apply_damage"):
		enemy.call("apply_damage", _damage, source)
	elif enemy.has_method("take_damage"):
		enemy.call("take_damage", _damage, source)
	if enemy is CharacterBody2D and _knockback > 0.0 and owner_node:
		var away: Vector2 = (enemy as Node2D).global_position - owner_node.global_position
		if away.length_squared() > 0.01:
			(enemy as CharacterBody2D).velocity += away.normalized() * (_knockback * 4.0)


func _resolve_enemy(node: Node) -> Node:
	if node == null:
		return null
	if node.is_in_group("enemy") or node.is_in_group("enemies"):
		return node
	var p := node.get_parent()
	if p and (p.is_in_group("enemy") or p.is_in_group("enemies")):
		return p
	return null
