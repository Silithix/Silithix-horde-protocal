extends CharacterBody2D
## Rook player: one-finger drag move, faces travel direction.
## Systems-owned. Weapons attached by Run (Combat scenes).

const MOVE_SPEED := 220.0
const MAX_HP := 100.0
const BASE_MAGNET_RADIUS := 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var magnet: Area2D = $Magnet

var hp: float = MAX_HP
var max_hp: float = MAX_HP
var magnet_radius: float = BASE_MAGNET_RADIUS
var level: int = 1
var xp: int = 0
var xp_to_next: int = 5
var alive: bool = true
var _drag_active: bool = false
var _drag_origin: Vector2 = Vector2.ZERO
var _move_dir: Vector2 = Vector2.ZERO
var _contact_cooldown: Dictionary = {}

signal died
signal leveled_up(new_level: int)
signal hp_changed(current: float, maximum: float)
signal xp_changed(current: int, to_next: int, lvl: int)

func _ready() -> void:
	add_to_group("player")
	set_meta("speed_mult", 1.0)
	_update_magnet_shape()
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	magnet.area_entered.connect(_on_magnet_area_entered)

func _physics_process(delta: float) -> void:
	if not alive:
		velocity = Vector2.ZERO
		return
	var keys := _contact_cooldown.keys()
	for k in keys:
		_contact_cooldown[k] = float(_contact_cooldown[k]) - delta
		if _contact_cooldown[k] <= 0.0:
			_contact_cooldown.erase(k)

	var speed := MOVE_SPEED * float(get_meta("speed_mult", 1.0))
	if _drag_active and _move_dir.length_squared() > 0.01:
		velocity = _move_dir.normalized() * speed
		sprite.rotation = _move_dir.angle() + PI * 0.5
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 4.0 * delta)
	move_and_slide()
	_tick_contact_overlaps()

func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_drag_active = true
			_drag_origin = touch.position
			_move_dir = Vector2.ZERO
		else:
			_drag_active = false
			_move_dir = Vector2.ZERO
	elif event is InputEventScreenDrag and _drag_active:
		var drag := event as InputEventScreenDrag
		var delta_pos: Vector2 = drag.position - _drag_origin
		if delta_pos.length() > 12.0:
			_move_dir = delta_pos
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_drag_active = true
			_drag_origin = event.position
			_move_dir = Vector2.ZERO
		else:
			_drag_active = false
			_move_dir = Vector2.ZERO
	elif event is InputEventMouseMotion and _drag_active and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var delta_pos2: Vector2 = event.position - _drag_origin
		if delta_pos2.length() > 12.0:
			_move_dir = delta_pos2

func apply_damage(amount: float, source: Node = null) -> void:
	if not alive or amount <= 0.0:
		return
	hp = maxf(0.0, hp - amount)
	Events.player_damaged.emit(amount, source)
	hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()

func heal(amount: float) -> void:
	if not alive:
		return
	hp = minf(max_hp, hp + amount)
	hp_changed.emit(hp, max_hp)

func add_xp(amount: int) -> void:
	if not alive or amount <= 0:
		return
	xp += amount
	Events.xp_gained.emit(amount)
	while xp >= xp_to_next:
		xp -= xp_to_next
		level += 1
		xp_to_next = _xp_curve(level)
		Events.player_leveled_up.emit(level)
		leveled_up.emit(level)
	xp_changed.emit(xp, xp_to_next, level)

func set_magnet_radius(radius: float) -> void:
	magnet_radius = radius
	_update_magnet_shape()


func _xp_curve(lvl: int) -> int:
	return 5 + (lvl - 1) * 3

func _die() -> void:
	alive = false
	velocity = Vector2.ZERO
	Events.player_died.emit()
	died.emit()

func _update_magnet_shape() -> void:
	var shape_node := magnet.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node and shape_node.shape is CircleShape2D:
		(shape_node.shape as CircleShape2D).radius = magnet_radius

func _on_hurtbox_body_entered(body: Node) -> void:
	_try_contact_damage(body)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	_try_contact_damage(area)

func _try_contact_damage(node: Node) -> void:
	if not alive:
		return
	if not node.is_in_group("enemy_contact"):
		return
	var id := node.get_instance_id()
	if _contact_cooldown.has(id):
		return
	var dmg := 8.0
	var tick := 0.4
	if node.has_meta("contact_damage"):
		dmg = float(node.get_meta("contact_damage"))
	if node.has_meta("contact_tick_s"):
		tick = float(node.get_meta("contact_tick_s"))
	_contact_cooldown[id] = tick
	apply_damage(dmg, node)

func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("magnet_pull"):
		area.call("magnet_pull", self)
