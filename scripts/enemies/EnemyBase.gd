extends CharacterBody2D
class_name EnemyBase
## Shared enemy: HP, apply_damage, pool hooks, seek stub. Groups: "enemy" + "enemies".

const POOL_KEY := &"enemy_base"

@export var move_speed: float = 70.0
@export var max_hp: float = 18.0
@export var contact_damage: float = 8.0
@export var contact_tick_s: float = 0.4
@export var xp_on_kill: int = 1
@export var gold_on_kill: int = 1

var hp: float = 18.0
var data_id: String = ""
var _active: bool = false
var _player: Node2D = null

@onready var contact: Area2D = get_node_or_null("Contact") as Area2D


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("enemies")
	_wire_contact()


func _wire_contact() -> void:
	if contact == null:
		return
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


func setup(target: Node2D, p_data_id: String = "") -> void:
	_player = target
	if p_data_id != "":
		data_id = p_data_id
	on_pool_acquire()


func is_alive() -> bool:
	return _active and hp > 0.0


func apply_damage(amount: float, _source: Node = null) -> void:
	if not _active or amount <= 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		_die()


## Alias kept for any Combat callers still using take_damage naming.
func take_damage(amount: float, source: Node = null) -> void:
	apply_damage(amount, source)


func _die() -> void:
	if not _active:
		return
	_active = false
	Events.enemy_killed.emit(self, gold_on_kill)
	var run := get_tree().get_first_node_in_group("run_root")
	if run and run.has_method("spawn_xp_gem"):
		run.call("spawn_xp_gem", global_position, xp_on_kill)
	Pool.release(_pool_key(), self)


func _pool_key() -> StringName:
	return POOL_KEY


func _physics_process(_delta: float) -> void:
	if not _active:
		return
	_ensure_player()
	if _player == null:
		velocity = Vector2.ZERO
		return
	_seek_player()


func _ensure_player() -> void:
	if _player != null and is_instance_valid(_player):
		return
	var players := get_tree().get_nodes_in_group("player")
	_player = players[0] if players.size() > 0 else null


func _seek_player() -> void:
	var dir := (_player.global_position - global_position)
	if dir.length_squared() > 1.0:
		velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
