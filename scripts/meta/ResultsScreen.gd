extends CanvasLayer
## Post-run results stub. Systems-owned Milestone B.

signal continue_pressed

@onready var title: Label = $Panel/VBox/Title
@onready var stats: Label = $Panel/VBox/Stats
@onready var cont: Button = $Panel/VBox/Continue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	cont.pressed.connect(_on_continue)

func show_results(payload: Dictionary) -> void:
	var won := bool(payload.get("won", false))
	title.text = "VICTORY" if won else "DEFEATED"
	var secs := int(payload.get("time_s", 0))
	var mm := secs / 60
	var ss := secs % 60
	stats.text = "Time  %d:%02d\nLevel  %d\nGold  %d\nKills  %d" % [
		mm, ss,
		int(payload.get("level", 1)),
		int(payload.get("gold", 0)),
		int(payload.get("kills", 0)),
	]
	visible = true
	get_tree().paused = true
	Events.pause_toggled.emit(true)

func _on_continue() -> void:
	visible = false
	get_tree().paused = false
	Events.pause_toggled.emit(false)
	continue_pressed.emit()
