extends Area2D
## XP gem pickup. Pool-friendly. Systems-owned.

const POOL_KEY := &"xp_gem"

@export var xp_value: int = 1

var _active: bool = false
var _pull_target: Node2D
var _pull_speed: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	add_to_group("xp_gem")

func on_pool_acquire() -> void:
	_active = true
	_pull_target = null
	_pull_speed = 0.0
	visible = true
	monitoring = true
	monitorable = true
	if collision:
		collision.disabled = false

func on_pool_release() -> void:
	_active = false
	_pull_target = null
	visible = false
	monitoring = false
	monitorable = false
	if collision:
		collision.disabled = true

func setup(value: int, pos: Vector2) -> void:
	xp_value = value
	global_position = pos
	on_pool_acquire()

func magnet_pull(player: Node2D) -> void:
	if not _active:
		return
	_pull_target = player
	_pull_speed = 480.0

func _physics_process(delta: float) -> void:
	if not _active or _pull_target == null or not is_instance_valid(_pull_target):
		return
	_pull_speed = minf(_pull_speed + 800.0 * delta, 900.0)
	global_position = global_position.move_toward(_pull_target.global_position, _pull_speed * delta)
	if global_position.distance_to(_pull_target.global_position) < 18.0:
		_collect(_pull_target)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_collect(body)

func _on_area_entered(area: Area2D) -> void:
	# Player magnet / hurtbox may be Area2D children; prefer body path
	var p := area.get_parent()
	if p and p.is_in_group("player"):
		_collect(p)

func _collect(player: Node) -> void:
	if not _active:
		return
	_active = false
	if player.has_method("add_xp"):
		player.call("add_xp", xp_value)
	Pool.release(POOL_KEY, self)
