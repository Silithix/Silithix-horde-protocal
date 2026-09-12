extends Camera2D
## Follows the player with light smoothing. Systems-owned.

@export var target_path: NodePath
@export var smooth_speed: float = 12.0

var _target: Node2D

func _ready() -> void:
	if target_path != NodePath(""):
		_target = get_node_or_null(target_path) as Node2D
	enabled = true
	make_current()

func set_target(node: Node2D) -> void:
	_target = node

func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		return
	global_position = global_position.lerp(_target.global_position, clampf(smooth_speed * delta, 0.0, 1.0))
