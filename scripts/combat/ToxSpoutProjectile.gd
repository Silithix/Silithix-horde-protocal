extends Area2D
class_name ToxSpoutProjectile
## Thin purple bolt — hits group "player" via apply_damage (else Events.player_damaged).

@export var lifetime_s: float = 3.0
@export var offscreen_margin: float = 128.0

var direction: Vector2 = Vector2.RIGHT
var speed: float = 220.0
var damage: float = 10.0
var source: Node = null
var _alive: bool = true
var _life_left: float = 3.0
var _hit: bool = false


func _ready() -> void:
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 1 # player body layer
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func launch(
	origin: Vector2,
	dir: Vector2,
	dmg: float,
	spd: float,
	p_source: Node = null
) -> void:
	global_position = origin
	direction = dir.normalized() if dir.length_squared() > 0.0 else Vector2.RIGHT
	damage = dmg
	speed = spd
	source = p_source
	rotation = direction.angle()
	_alive = true
	_hit = false
	_life_left = lifetime_s


func _physics_process(delta: float) -> void:
	if not _alive:
		return
	global_position += direction * speed * delta
	_life_left -= delta
	if _life_left <= 0.0 or _is_offscreen():
		_despawn()


func _is_offscreen() -> bool:
	var vp := get_viewport()
	if vp == null:
		return false
	var rect := vp.get_visible_rect().grow(offscreen_margin)
	var canvas_pos := get_global_transform_with_canvas().origin
	return not rect.has_point(canvas_pos)


func _on_body_entered(body: Node) -> void:
	_try_hit(body)


func _on_area_entered(area: Area2D) -> void:
	_try_hit(area)


func _try_hit(node: Node) -> void:
	if not _alive or _hit or node == null:
		return
	if source != null and (node == source or node.get_parent() == source):
		return
	var player := _resolve_player(node)
	if player == null:
		return
	_hit = true
	var src: Node = source if source else self
	if player.has_method("apply_damage"):
		player.call("apply_damage", damage, src)
	else:
		Events.player_damaged.emit(damage, src)
	_despawn()


func _resolve_player(node: Node) -> Node:
	if node.is_in_group("player"):
		return node
	var p := node.get_parent()
	if p and p.is_in_group("player"):
		return p
	return null


func _despawn() -> void:
	_alive = false
	queue_free()
