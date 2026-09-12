extends Area2D
## Mid-run crate. Systems collect logic + proximity fallback (QA-B1).

const POOL_KEY := &"crate"
const PICKUP_RADIUS := 56.0

var _active: bool = false
var _kind: String = "heal_meat"
var _bob_t: float = 0.0

@onready var visual: CanvasItem = get_node_or_null("Visual")
@onready var body_poly: Polygon2D = get_node_or_null("Body")
@onready var lid_poly: Polygon2D = get_node_or_null("Lid")
@onready var band: Polygon2D = get_node_or_null("Band")
@onready var label: Label = get_node_or_null("Label")
@onready var beacon: Polygon2D = get_node_or_null("Beacon")
@onready var collision: CollisionShape2D = get_node_or_null("CollisionShape2D")

# Optional Art textures if present on scene Visual Sprite2D
const TEX_PATHS := {
	"heal_meat": "res://assets/sprites/props/crate_heal.png",
	"magnet": "res://assets/sprites/props/crate_magnet.png",
	"gold_bag": "res://assets/sprites/props/crate_gold.png",
	"_": "res://assets/sprites/props/crate_placeholder.png",
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("crate")
	_ensure_beacon()
	_restyle()

func on_pool_acquire() -> void:
	_active = true
	_bob_t = 0.0
	visible = true
	monitoring = true
	monitorable = true
	set_physics_process(true)
	if collision:
		collision.set_deferred("disabled", false)
	_ensure_beacon()
	_restyle()

func on_pool_release() -> void:
	_active = false
	visible = false
	monitoring = false
	monitorable = false
	set_physics_process(false)
	if collision:
		collision.set_deferred("disabled", true)

func setup(pos: Vector2, kind: String = "heal_meat") -> void:
	global_position = pos
	_kind = kind
	on_pool_acquire()

## Public: Player magnet / Run can force pickup.
func try_pickup(player: Node) -> bool:
	if not _active or player == null or not player.is_in_group("player"):
		return false
	_collect(player)
	return true

func _physics_process(delta: float) -> void:
	if not _active:
		return
	_bob_t += delta
	if beacon:
		var pulse := 0.55 + 0.45 * absf(sin(_bob_t * 4.0))
		beacon.modulate.a = pulse
		beacon.scale = Vector2.ONE * (1.0 + 0.15 * sin(_bob_t * 4.0))
	# Proximity fallback — does not rely on Area body signals
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node2D = players[0]
	if player.global_position.distance_to(global_position) <= PICKUP_RADIUS:
		_collect(player)

func _ensure_beacon() -> void:
	if beacon != null:
		return
	var b := Polygon2D.new()
	b.name = "Beacon"
	b.z_index = -1
	b.color = Color(1.0, 0.95, 0.2, 0.7)
	b.polygon = PackedVector2Array([
		Vector2(0, -48), Vector2(14, -20), Vector2(40, -20), Vector2(18, -2),
		Vector2(26, 28), Vector2(0, 12), Vector2(-26, 28), Vector2(-18, -2),
		Vector2(-40, -20), Vector2(-14, -20)
	])
	add_child(b)
	beacon = b

func _restyle() -> void:
	if label:
		label.text = _label_for_kind()
	# Prefer Art Sprite2D textures when Visual is Sprite2D
	if visual is Sprite2D:
		var path: String = TEX_PATHS.get(_kind, TEX_PATHS["_"])
		if ResourceLoader.exists(path):
			(visual as Sprite2D).texture = load(path) as Texture2D
		return
	# Systems poly fallback (cyan ≠ Hound)
	if body_poly:
		body_poly.color = Color(0.15, 0.75, 0.85, 1.0)
	if lid_poly:
		lid_poly.color = Color(1.0, 0.92, 0.25, 1.0)
	if band:
		band.color = Color(0.05, 0.08, 0.12, 1.0)

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
	_try_collect(p if p else area)

func _try_collect(node: Node) -> void:
	if not _active or node == null:
		return
	var player: Node = node
	if not player.is_in_group("player"):
		player = node.get_parent() if node.get_parent() else null
	if player == null or not player.is_in_group("player"):
		return
	_collect(player)

func _collect(player: Node) -> void:
	if not _active:
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
	toast.add_theme_color_override("font_outline_color", Color(0.043, 0.059, 0.102, 1.0))
	toast.add_theme_constant_override("outline_size", 6)
	if text.begins_with("FULL") or "GOLD" in text:
		toast.modulate = Color(1.0, 0.83, 0.36, 1.0)
	elif text.begins_with("+") and "HP" in text:
		toast.modulate = Color(0.239, 1.0, 0.604, 1.0)
	elif "MAGNET" in text:
		toast.modulate = Color(0.361, 0.722, 1.0, 1.0)
	else:
		toast.modulate = Color(1.0, 0.95, 0.35, 1.0)
	toast.global_position = global_position + Vector2(-48, -56)
	run.add_child(toast)
	var tw := toast.create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(toast, "global_position", toast.global_position + Vector2(0, -80), 0.7)
	tw.parallel().tween_property(toast, "modulate:a", 0.0, 0.7)
	tw.tween_callback(toast.queue_free)
