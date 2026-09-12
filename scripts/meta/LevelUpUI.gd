extends CanvasLayer
## Pauses the tree and shows 3 cards. Queues multi-level ups. Systems-owned.

signal card_picked(card_id: String)

@onready var panel: Control = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var buttons: Array[Button] = [
	$Panel/VBox/Card0 as Button,
	$Panel/VBox/Card1 as Button,
	$Panel/VBox/Card2 as Button,
]

var _open: bool = false
var _level_queue: Array[int] = []

const DUMMY_CARDS := [
	{"id": "shard_knives", "label": "Shard Knives\nUpgrade weapon"},
	{"id": "move_speed", "label": "Boots\n+12% move speed"},
	{"id": "magnet", "label": "Magnet Coil\n+40 magnet radius"},
	{"id": "max_hp", "label": "Plating\n+20 max HP + heal"},
	{"id": "xp_gain", "label": "Scavenger\n+1 bonus XP on gem"},
	{"id": "heal", "label": "Field Ration\nHeal 30 HP"},
]

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in buttons.size():
		var b := buttons[i]
		b.pressed.connect(_on_card_pressed.bind(i))

func show_level_up(new_level: int) -> void:
	_level_queue.append(new_level)
	if not _open:
		_present_next()

func is_open() -> bool:
	return _open

func force_close() -> void:
	_level_queue.clear()
	_open = false
	visible = false
	if get_tree():
		get_tree().paused = false
	Events.pause_toggled.emit(false)

func _unhandled_input(event: InputEvent) -> void:
	# Esc during level-up abandons to hub via Run; just ensure we don't eat picks.
	pass

func _present_next() -> void:
	if _level_queue.is_empty():
		_open = false
		visible = false
		get_tree().paused = false
		Events.pause_toggled.emit(false)
		return
	var new_level: int = _level_queue.pop_front()
	_open = true
	title_label.text = "LEVEL %d — pick one" % new_level
	var picks := DUMMY_CARDS.duplicate()
	picks.shuffle()
	for i in buttons.size():
		var card: Dictionary = picks[i]
		buttons[i].text = String(card["label"])
		buttons[i].set_meta("card_id", String(card["id"]))
	visible = true
	get_tree().paused = true
	Events.pause_toggled.emit(true)

func _on_card_pressed(index: int) -> void:
	if not _open:
		return
	var card_id := String(buttons[index].get_meta("card_id"))
	card_picked.emit(card_id)
	if _level_queue.is_empty():
		_open = false
		visible = false
		get_tree().paused = false
		Events.pause_toggled.emit(false)
	else:
		_present_next()
