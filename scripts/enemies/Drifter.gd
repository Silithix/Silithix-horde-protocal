extends EnemyBase
class_name Drifter
## Trash melee seeker — drop-in upgrade for TempSeeker (pool key "drifter").

const POOL_KEY := &"drifter"
const DEFAULT_DATA_ID := "drifter"

@onready var visual: Node2D = get_node_or_null("Visual") as Node2D


func _ready() -> void:
	data_id = DEFAULT_DATA_ID
	super._ready()
	if visual == null:
		_ensure_visual()


func _pool_key() -> StringName:
	return POOL_KEY


## Public API: load data + bind seek target (player).
func setup(target: Node2D, p_data_id: String = "drifter") -> void:
	_load_data(p_data_id)
	super.setup(target, p_data_id)


func activate(pos: Vector2, player: Node2D) -> void:
	if data_id == "" or max_hp <= 0.0:
		_load_data(DEFAULT_DATA_ID)
	super.activate(pos, player)


func _load_data(p_data_id: String) -> void:
	data_id = p_data_id if p_data_id != "" else DEFAULT_DATA_ID
	var data := CombatData.load_enemy(data_id)
	if data.is_empty():
		push_warning("Drifter: missing data for %s — using defaults" % data_id)
		return
	max_hp = float(data.get("hp", 18))
	hp = max_hp
	move_speed = float(data.get("move_speed_px_s", 70))
	contact_damage = float(data.get("contact_damage", 8))
	contact_tick_s = float(data.get("contact_tick_s", 0.4))
	gold_on_kill = int(data.get("gold_drop", 1))
	# xp_drop may be gem id string; TempSeeker uses int count — keep 1 for trash.
	xp_on_kill = 1
	_wire_contact()


func _seek_player() -> void:
	var dir := (_player.global_position - global_position)
	if dir.length_squared() > 1.0:
		velocity = dir.normalized() * move_speed
		if visual:
			visual.rotation = dir.angle() + PI * 0.5
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func _ensure_visual() -> void:
	var spr := Sprite2D.new()
	spr.name = "Visual"
	spr.scale = Vector2(0.7, 0.7)
	var tex := load("res://assets/sprites/enemies/walker_placeholder.png")
	if tex:
		spr.texture = tex
	add_child(spr)
	visual = spr
