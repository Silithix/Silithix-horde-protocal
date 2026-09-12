extends Node
## Object pool. Systems owns warm + acquire/release behavior.
## Public API locked with Arch: warm / acquire / release.

var _pools: Dictionary = {} # StringName -> Array[Node]
var _scenes: Dictionary = {} # StringName -> PackedScene

func warm(key: StringName, scene: PackedScene, count: int) -> void:
	if scene == null or count <= 0:
		return
	_scenes[key] = scene
	if not _pools.has(key):
		_pools[key] = []
	var list: Array = _pools[key]
	# Instantiate only — do not call on_pool_release before enter_tree/_ready.
	while list.size() < count:
		list.append(scene.instantiate())
	_pools[key] = list

func acquire(key: StringName, parent: Node) -> Node:
	var list: Array = _pools.get(key, [])
	var node: Node
	if list.size() > 0:
		node = list.pop_back()
	else:
		var scene: PackedScene = _scenes.get(key, null)
		if scene:
			node = scene.instantiate()
		else:
			push_warning("Pool: miss for %s — warm pools first" % String(key))
			return null
	if parent:
		parent.add_child(node)
	if node.has_method("on_pool_acquire"):
		node.call("on_pool_acquire")
	return node

func release(key: StringName, node: Node) -> void:
	if node == null:
		return
	if node.get_parent():
		node.get_parent().remove_child(node)
	if node.has_method("on_pool_release"):
		node.call("on_pool_release")
	if not _pools.has(key):
		_pools[key] = []
	_pools[key].append(node)
