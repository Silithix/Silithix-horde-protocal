extends EnemyBase
class_name PlatedDrifter
## Slow high-HP armored seeker — grey/steel tint. Data id "plated_drifter".

const DEFAULT_DATA_ID := "plated_drifter"
const STEEL_TINT := Color(0.55, 0.60, 0.68, 1.0)

@onready var visual: Node2D = get_node_or_null("Visual") as Node2D


func _ready() -> void:
	data_id = DEFAULT_DATA_ID
	super._ready()
	if visual == null:
		_ensure_visual()
	_apply_steel_tint()


func _pool_key() -> StringName:
	return &"plated_drifter"


## Public API: load data + bind seek target (player).
func setup(target: Node2D, p_data_id: String = "plated_drifter") -> void:
	_load_data(p_data_id)
	super.setup(target, p_data_id)


func activate(pos: Vector2, player: Node2D) -> void:
	if data_id == "" or max_hp <= 0.0:
		_load_data(DEFAULT_DATA_ID)
	super.activate(pos, player)
	_apply_steel_tint()


func _load_data(p_data_id: String) -> void:
	data_id = p_data_id if p_data_id != "" else DEFAULT_DATA_ID
	var data := CombatData.load_enemy(data_id)
	if data.is_empty():
		push_warning("PlatedDrifter: missing data for %s — using defaults" % data_id)
		return
	max_hp = float(data.get("hp", 55))
	hp = max_hp
	move_speed = float(data.get("move_speed_px_s", 55))
	contact_damage = float(data.get("contact_damage", 10))
	contact_tick_s = float(data.get("contact_tick_s", 0.4))
	gold_on_kill = int(data.get("gold_drop", 2))
	# xp_drop may be gem id string; keep 1 trash gem count for Systems spawn_xp_gem.
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


func _apply_steel_tint() -> void:
	if visual:
		visual.modulate = STEEL_TINT


func _ensure_visual() -> void:
	var spr := Sprite2D.new()
	spr.name = "Visual"
	spr.scale = Vector2(0.85, 0.85)
	spr.modulate = STEEL_TINT
	var tex := load("res://assets/sprites/enemies/plated_drifter_placeholder.png")
	if tex:
		spr.texture = tex
	add_child(spr)
	visual = spr
