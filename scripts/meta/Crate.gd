extends Area2D
## Mid-run crate. Systems-owned. Contents from pickup_table feel.

const POOL_KEY := &"crate"

var _active: bool = false
var _kind: String = "heal_meat"

@onready var visual: Polygon2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("crate")

func on_pool_acquire() -> void:
	_active = true
	visible = true
	monitoring = true
	if collision:
		collision.disabled = false

func on_pool_release() -> void:
	_active = false
	visible = false
	monitoring = false
	if collision:
		collision.disabled = true

func setup(pos: Vector2, kind: String = "heal_meat") -> void:
	global_position = pos
	_kind = kind
	on_pool_acquire()

func _on_body_entered(body: Node) -> void:
	if not _active:
		return
	if not body.is_in_group("player"):
		return
	_active = false
	_apply(body)
	Pool.release(POOL_KEY, self)

func _apply(player: Node) -> void:
	match _kind:
		"heal_meat":
			if player.has_method("heal"):
				var mx := float(player.get("max_hp"))
				player.call("heal", mx * 0.2)
		"magnet":
			var run := get_tree().get_first_node_in_group("run_root")
			if run and run.has_method("vacuum_all_gems"):
				run.call("vacuum_all_gems")
		"gold_bag":
			# Meta gold later; Milestone B: small heal consolation
			if player.has_method("heal"):
				player.call("heal", 10.0)
		_:
			if player.has_method("heal"):
				player.call("heal", 15.0)
