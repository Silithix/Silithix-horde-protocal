extends Area2D
class_name ShardKnifeProjectile
## Flying shard knife — damages nodes in group "enemy" via apply_damage.

@export var lifetime_s: float = 1.6
@export var offscreen_margin: float = 128.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 420.0
var damage: float = 12.0
var pierce_left: int = 0
var source: Node = null
var _alive: bool = true
var _life_left: float = 1.6
var _hit_ids: Dictionary = {}


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 2 # enemy body layer (TempSeeker / Drifter)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func launch(
	origin: Vector2,
	dir: Vector2,
	dmg: float,
	spd: float,
	pierce: int = 0,
	p_source: Node = null
) -> void:
	global_position = origin
	direction = dir.normalized() if dir.length_squared() > 0.0 else Vector2.RIGHT
	damage = dmg
	speed = spd
	pierce_left = pierce
	source = p_source
	rotation = direction.angle()
	_alive = true
	_life_left = lifetime_s
	_hit_ids.clear()


func _physics_process(delta: float) -> void:
	if not _alive:
		return
	global_position += direction * speed * delta
	_life_left -= delta
	if _life_left <= 0.0 or _is_offscreen():
		_despawn()


func _is_offscreen() -> bool:
	var rect := get_viewport().get_visible_rect().grow(offscreen_margin)
	var canvas_pos := get_global_transform_with_canvas().origin
	return not rect.has_point(canvas_pos)


func _on_body_entered(body: Node) -> void:
	_try_hit(body)


func _on_area_entered(area: Area2D) -> void:
	_try_hit(area)


func _try_hit(node: Node) -> void:
	if not _alive or node == null:
		return
	var enemy: Node = _resolve_enemy(node)
	if enemy == null:
		return
	var id := enemy.get_instance_id()
	if _hit_ids.has(id):
		return
	_hit_ids[id] = true
	if enemy.has_method("apply_damage"):
		enemy.call("apply_damage", damage, source if source else self)
	elif enemy.has_method("take_damage"):
		enemy.call("take_damage", damage, source if source else self)
	if pierce_left <= 0:
		_despawn()
	else:
		pierce_left -= 1


func _resolve_enemy(node: Node) -> Node:
	if node.is_in_group("enemy"):
		return node
	var p := node.get_parent()
	if p and p.is_in_group("enemy"):
		return p
	return null


func _despawn() -> void:
	_alive = false
	queue_free()
