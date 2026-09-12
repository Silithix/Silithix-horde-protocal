extends Node2D
class_name WeaponBase
## Base auto-fire weapon: cooldown, level, owner Node2D, nearest-enemy targeting.

var owner_node: Node2D = null
var level: int = 1
var cooldown: float = 1.0
var _cooldown_left: float = 0.0


func setup(p_owner: Node2D) -> void:
	owner_node = p_owner
	_cooldown_left = 0.0


func set_level(p_level: int) -> void:
	level = maxi(1, p_level)
	_apply_level_stats()


func _apply_level_stats() -> void:
	pass


func _process(delta: float) -> void:
	if owner_node == null or not is_instance_valid(owner_node):
		return
	_cooldown_left -= delta
	if _cooldown_left <= 0.0:
		if _try_fire():
			_cooldown_left = cooldown
		else:
			_cooldown_left = minf(0.1, cooldown)


func _try_fire() -> bool:
	return false


func find_nearest_enemy() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var origin: Vector2 = owner_node.global_position if owner_node else global_position
	var best: Node2D = null
	var best_d: float = INF
	var seen: Dictionary = {}
	for group_name in ["enemy", "enemies"]:
		for node in tree.get_nodes_in_group(group_name):
			if seen.has(node):
				continue
			seen[node] = true
			if not is_instance_valid(node) or not (node is Node2D):
				continue
			var enemy := node as Node2D
			if enemy.has_method("is_alive") and not bool(enemy.call("is_alive")):
				continue
			var d: float = origin.distance_squared_to(enemy.global_position)
			if d < best_d:
				best_d = d
				best = enemy
	return best


func get_fire_origin() -> Vector2:
	if owner_node and is_instance_valid(owner_node):
		return owner_node.global_position
	return global_position
