extends CharacterBody2D
## Milestone A kite dummy. Systems stand-in until Combat ships Drifter scene.
## Not under scripts/enemies/ — Combat owns that path.

const POOL_KEY := &"temp_seeker"

@export var move_speed: float = 70.0
@export var max_hp: float = 18.0
@export var contact_damage: float = 8.0
@export var contact_tick_s: float = 0.4
@export var xp_on_kill: int = 1
@export var gold_on_kill: int = 1

var hp: float = 18.0
var _active: bool = false
var _player: Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var contact: Area2D = $Contact

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("enemies")
	contact.add_to_group("enemy_contact")
	contact.set_meta("contact_damage", contact_damage)
	contact.set_meta("contact_tick_s", contact_tick_s)

func on_pool_acquire() -> void:
	_active = true
	hp = max_hp
	visible = true
	set_physics_process(true)
	if contact:
		contact.monitoring = true
		contact.monitorable = true
		contact.set_meta("contact_damage", contact_damage)
		contact.set_meta("contact_tick_s", contact_tick_s)

func on_pool_release() -> void:
	_active = false
	_player = null
	visible = false
	set_physics_process(false)
	if contact:
		contact.monitoring = false
		contact.monitorable = false
	velocity = Vector2.ZERO

func activate(pos: Vector2, player: Node2D) -> void:
	global_position = pos
	_player = player
	on_pool_acquire()

func is_alive() -> bool:
	return _active and hp > 0.0

func take_damage(amount: float, source: Node = null) -> void:
	apply_damage(amount, source)

func apply_damage(amount: float, _source: Node = null) -> void:
	if not _active:
		return
	hp -= amount
	if hp <= 0.0:
		_die()

func _physics_process(_delta: float) -> void:
	if not _active:
		return
	if _player == null or not is_instance_valid(_player):
		var players := get_tree().get_nodes_in_group("player")
		_player = players[0] if players.size() > 0 else null
		if _player == null:
			velocity = Vector2.ZERO
			return
	var dir := (_player.global_position - global_position)
	if dir.length_squared() > 1.0:
		velocity = dir.normalized() * move_speed
		sprite.rotation = dir.angle() + PI * 0.5
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _die() -> void:
	if not _active:
		return
	_active = false
	Events.enemy_killed.emit(self, gold_on_kill)
	# Drop XP via Run helper if present
	var run := get_tree().get_first_node_in_group("run_root")
	if run and run.has_method("spawn_xp_gem"):
		run.call("spawn_xp_gem", global_position, xp_on_kill)
	Pool.release(POOL_KEY, self)
