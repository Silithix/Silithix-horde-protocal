extends Control
## Cold boot → Hub. Arch-owned entry.

func _ready() -> void:
	# One frame so autoloads finish; then hub.
	await get_tree().process_frame
	Game.go_to_hub()
