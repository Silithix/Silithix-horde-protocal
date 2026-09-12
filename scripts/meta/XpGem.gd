extends Area2D
## XP gem pickup with tiers. Pool-friendly. Systems-owned.

const POOL_KEY := &"xp_gem"

@export var xp_value: int = 1

var _active: bool = false
var _pull_target: Node2D
var _pull_speed: float = 0.0
var _tier: String = "small_green"

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

const TIER_VISUAL := {
	"small_green": {"xp": 1, "scale": 0.55, "mod": Color(0.35, 0.95, 0.45)},
	"large_green": {"xp": 3, "scale": 0.85, "mod": Color(0.2, 0.85, 0.35)},
	"blue": {"xp": 8, "scale": 1.0, "mod": Color(0.35, 0.55, 1.0)},
	"gold": {"xp": 20, "scale": 1.15, "mod": Color(1.0, 0.85, 0.2)},
}

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

func setup(value: int, pos: Vector2, tier: String = "") -> void:
	if tier != "" and TIER_VISUAL.has(tier):
		_tier = tier
		xp_value = int(TIER_VISUAL[tier]["xp"])
	elif value > 0:
		xp_value = value
		_tier = _tier_for_xp(value)
	else:
		_tier = "small_green"
		xp_value = 1
	_apply_visual()
	global_position = pos
	on_pool_acquire()

func setup_tier(tier: String, pos: Vector2) -> void:
	setup(0, pos, tier)

func magnet_pull(player: Node2D) -> void:
	if not _active:
		return
	_pull_target = player
	_pull_speed = 480.0

func _apply_visual() -> void:
	var vis: Dictionary = TIER_VISUAL.get(_tier, TIER_VISUAL["small_green"])
	if sprite:
		sprite.scale = Vector2.ONE * float(vis["scale"])
		sprite.modulate = vis["mod"] as Color

func _tier_for_xp(value: int) -> String:
	if value >= 20:
		return "gold"
	if value >= 8:
		return "blue"
	if value >= 3:
		return "large_green"
	return "small_green"

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
