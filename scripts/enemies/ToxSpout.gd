extends EnemyBase
class_name ToxSpout
## Mid-range spitter — stop at range, telegraph, fire purple bolt at player.

const DEFAULT_DATA_ID := "tox_spout"
const PROJECTILE_SCENE := preload("res://scenes/combat/ToxSpoutProjectile.tscn")
const PREFERRED_RANGE_PX := 280.0
const RANGE_SLACK_PX := 36.0

@onready var visual: Node2D = get_node_or_null("Visual") as Node2D

var _proj_damage: float = 10.0
var _proj_speed: float = 220.0
var _proj_cooldown: float = 1.6
var _telegraph_s: float = 0.25
var _preferred_range: float = PREFERRED_RANGE_PX
var _cooldown_left: float = 0.4
var _telegraphing: bool = false
var _telegraph_left: float = 0.0
var _base_modulate: Color = Color.WHITE


func _ready() -> void:
	data_id = DEFAULT_DATA_ID
	super._ready()
	if visual == null:
		_ensure_visual()
	if visual:
		_base_modulate = visual.modulate


func _pool_key() -> StringName:
	return &"tox_spout"


func setup(target: Node2D, p_data_id: String = "tox_spout") -> void:
	_load_data(p_data_id)
	super.setup(target, p_data_id)


func activate(pos: Vector2, player: Node2D) -> void:
	if data_id == "" or max_hp <= 0.0:
		_load_data(DEFAULT_DATA_ID)
	super.activate(pos, player)


func on_pool_acquire() -> void:
	super.on_pool_acquire()
	_cooldown_left = 0.35
	_telegraphing = false
	_telegraph_left = 0.0
	_restore_visual()


func on_pool_release() -> void:
	_telegraphing = false
	_telegraph_left = 0.0
	_restore_visual()
	super.on_pool_release()


func _load_data(p_data_id: String) -> void:
	data_id = p_data_id if p_data_id != "" else DEFAULT_DATA_ID
	var data := CombatData.load_enemy(data_id)
	if data.is_empty():
		push_warning("ToxSpout: missing data for %s — using defaults" % data_id)
		return
	max_hp = float(data.get("hp", 16))
	hp = max_hp
	move_speed = float(data.get("move_speed_px_s", 55))
	contact_damage = float(data.get("contact_damage", 6))
	contact_tick_s = float(data.get("contact_tick_s", 0.4))
	gold_on_kill = int(data.get("gold_drop", 1))
	xp_on_kill = 1
	_telegraph_s = float(data.get("telegraph_s", 0.25))
	var proj: Variant = data.get("projectile", {})
	if typeof(proj) == TYPE_DICTIONARY:
		var pd: Dictionary = proj
		_proj_damage = float(pd.get("damage", 10))
		_proj_speed = float(pd.get("speed_px_s", 220))
		_proj_cooldown = float(pd.get("cooldown_s", 1.6))
		_telegraph_s = float(pd.get("telegraph_s", _telegraph_s))
	_wire_contact()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not _active:
		return
	_tick_attack(delta)


func _seek_player() -> void:
	var dir := (_player.global_position - global_position)
	var dist := dir.length()
	if visual and dist > 1.0:
		visual.rotation = dir.angle() + PI * 0.5
	if _telegraphing:
		velocity = Vector2.ZERO
	elif dist > _preferred_range:
		velocity = dir.normalized() * move_speed
	elif dist > _preferred_range - RANGE_SLACK_PX:
		velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _tick_attack(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var dist := global_position.distance_to(_player.global_position)
	if _telegraphing:
		_telegraph_left -= delta
		_apply_telegraph_visual()
		if _telegraph_left <= 0.0:
			_telegraphing = false
			_restore_visual()
			_fire_at_player()
			_cooldown_left = _proj_cooldown
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0 and dist <= _preferred_range + RANGE_SLACK_PX:
		_start_telegraph()


func _start_telegraph() -> void:
	_telegraphing = true
	_telegraph_left = maxf(0.05, _telegraph_s)
	_apply_telegraph_visual()


func _apply_telegraph_visual() -> void:
	if visual == null:
		return
	# Crouch + warn flash (art bible `warn`).
	var pulse := 0.55 + 0.45 * sin(_telegraph_left * 28.0)
	visual.modulate = Color(1.0, 0.77, 0.24, 1.0) * Color(pulse, pulse, pulse, 1.0)
	visual.scale = Vector2(1.0, 0.82)


func _restore_visual() -> void:
	if visual == null:
		return
	visual.modulate = _base_modulate
	visual.scale = Vector2.ONE


func _fire_at_player() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var origin := global_position
	var dir := (_player.global_position - origin)
	if dir.length_squared() < 0.001:
		dir = Vector2.RIGHT
	else:
		dir = dir.normalized()
	var proj: Node = PROJECTILE_SCENE.instantiate()
	var host := _projectile_parent()
	host.add_child(proj)
	if proj.has_method("launch"):
		proj.call("launch", origin + dir * 22.0, dir, _proj_damage, _proj_speed, self)
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
			var e := run.get_node_or_null("Entities")
			if e:
				return e
	if get_parent():
		return get_parent()
	return self


func _ensure_visual() -> void:
	var wrap := Node2D.new()
	wrap.name = "Visual"
	var body := ColorRect.new()
	body.name = "Body"
	body.size = Vector2(32, 36)
	body.position = Vector2(-16, -18)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.color = Color(0.69, 0.42, 1.0)
	var snout := ColorRect.new()
	snout.name = "Snout"
	snout.size = Vector2(10, 12)
	snout.position = Vector2(-5, -28)
	snout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	snout.color = Color(0.82, 0.55, 1.0)
	wrap.add_child(body)
	wrap.add_child(snout)
	add_child(wrap)
	visual = wrap
	_base_modulate = wrap.modulate
