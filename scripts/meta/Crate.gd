extends Area2D
## Mid-run crate — high-contrast loot box (not enemy-colored). Systems-owned.

const POOL_KEY := &"crate"

var _active: bool = false
var _kind: String = "heal_meat"

@onready var body_poly: Polygon2D = $Body
@onready var lid_poly: Polygon2D = $Lid
@onready var band: Polygon2D = $Band
@onready var label: Label = $Label
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("crate")
	_restyle()

func on_pool_acquire() -> void:
	_active = true
	visible = true
	monitoring = true
	monitorable = true
	if collision:
		collision.set_deferred("disabled", false)
	_restyle()

func on_pool_release() -> void:
	_active = false
	visible = false
	monitoring = false
	monitorable = false
	if collision:
		collision.set_deferred("disabled", true)

func setup(pos: Vector2, kind: String = "heal_meat") -> void:
	global_position = pos
	_kind = kind
	on_pool_acquire()

func _restyle() -> void:
	# Cyan crate + yellow lid — intentionally not Hound brown/orange.
	if body_poly:
		body_poly.color = Color(0.15, 0.75, 0.85, 1.0)
	if lid_poly:
		lid_poly.color = Color(1.0, 0.92, 0.25, 1.0)
	if band:
		band.color = Color(0.05, 0.08, 0.12, 1.0)
	if label:
		label.text = _label_for_kind()
		label.modulate = Color(1, 1, 1, 1)

func _label_for_kind() -> String:
	match _kind:
		"heal_meat":
			return "HEAL"
		"magnet":
			return "MAG"
		"gold_bag":
			return "GOLD"
		_:
			return "CRATE"

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _on_area_entered(area: Area2D) -> void:
	var p := area.get_parent()
	if p:
		_try_collect(p)
	else:
		_try_collect(area)

func _try_collect(node: Node) -> void:
	if not _active or node == null:
		return
	var player: Node = node
	if not player.is_in_group("player"):
		player = node.get_parent() if node.get_parent() else null
	if player == null or not player.is_in_group("player"):
		return
	_active = false
	var msg := _apply(player)
	_spawn_toast(msg)
	Pool.release(POOL_KEY, self)

func _apply(player: Node) -> String:
	match _kind:
		"heal_meat":
			if player.has_method("heal"):
				var before := float(player.get("hp"))
				var mx := float(player.get("max_hp"))
				player.call("heal", mx * 0.2)
				var after := float(player.get("hp"))
				var gained := after - before
				if gained <= 0.05:
					return "FULL HP"
				return "+%d HP" % int(round(gained))
			return "HEAL"
		"magnet":
			var run := get_tree().get_first_node_in_group("run_root")
			if run and run.has_method("vacuum_all_gems"):
				run.call("vacuum_all_gems")
			return "MAGNET!"
		"gold_bag":
			if player.has_method("heal"):
				var before := float(player.get("hp"))
				player.call("heal", 10.0)
				var after := float(player.get("hp"))
				if after - before <= 0.05:
					return "+GOLD (FULL HP)"
				return "+GOLD +HP"
			return "+GOLD"
		_:
			if player.has_method("heal"):
				player.call("heal", 15.0)
			return "LOOT"

func _spawn_toast(text: String) -> void:
	var run := get_tree().get_first_node_in_group("run_root")
	if run == null:
		return
	var toast := Label.new()
	toast.text = text
	toast.z_index = 50
	toast.add_theme_font_size_override("font_size", 36)
	toast.modulate = Color(1.0, 0.95, 0.35, 1.0)
	toast.global_position = global_position + Vector2(-40, -50)
	run.add_child(toast)
	var tw := toast.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(toast, "global_position", toast.global_position + Vector2(0, -80), 0.7)
	tw.parallel().tween_property(toast, "modulate:a", 0.0, 0.7)
	tw.tween_callback(toast.queue_free)
