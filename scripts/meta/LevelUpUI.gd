extends CanvasLayer
## Pauses the tree and shows 3 dummy cards. Systems-owned Milestone A.

signal card_picked(card_id: String)

@onready var panel: Control = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var buttons: Array[Button] = [
	$Panel/VBox/Card0 as Button,
	$Panel/VBox/Card1 as Button,
	$Panel/VBox/Card2 as Button,
]

var _open: bool = false

const DUMMY_CARDS := [
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
	if _open:
		return
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
	_open = false
	visible = false
	get_tree().paused = false
	Events.pause_toggled.emit(false)
	card_picked.emit(card_id)
