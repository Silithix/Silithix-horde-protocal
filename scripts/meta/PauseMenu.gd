extends CanvasLayer
## Run pause: Resume / Hub. Systems-owned Milestone B.

signal resume_pressed
signal hub_pressed

@onready var panel: Control = $Panel

var _open: bool = false

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/VBox/Resume.pressed.connect(_on_resume)
	$Panel/VBox/Hub.pressed.connect(_on_hub)

func open_menu() -> void:
	if _open:
		return
	_open = true
	visible = true
	get_tree().paused = true
	Events.pause_toggled.emit(true)

func close_menu(unpause: bool = true) -> void:
	_open = false
	visible = false
	if unpause and get_tree():
		get_tree().paused = false
		Events.pause_toggled.emit(false)

func is_open() -> bool:
	return _open

func _on_resume() -> void:
	close_menu(true)
	resume_pressed.emit()

func _on_hub() -> void:
	close_menu(false)
	if get_tree():
		get_tree().paused = false
	Events.pause_toggled.emit(false)
	hub_pressed.emit()
