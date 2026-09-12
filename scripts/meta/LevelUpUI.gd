extends CanvasLayer
## Pauses the tree and shows 3 cards. Queues multi-level ups. Systems-owned.
## Respects 6-weapon hard cap when filtering new-weapon offers.

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
var _owned_weapons: Array[String] = []
var _weapon_count: int = 1
const MAX_WEAPONS := 6

## kind: "upgrade_weapon" | "new_weapon" | "passive"
const CARD_DEFS := [
	{"id": "shard_knives", "label": "Shard Knives\nUpgrade weapon", "kind": "upgrade_weapon", "weapon": "shard_knives"},
	{"id": "pulse_halo", "label": "Pulse Halo\nDamaging ring", "kind": "new_weapon", "weapon": "pulse_halo"},
	{"id": "pulse_halo_up", "label": "Pulse Halo\nUpgrade ring", "kind": "upgrade_weapon", "weapon": "pulse_halo"},
	{"id": "move_speed", "label": "Boots\n+12% move speed", "kind": "passive"},
	{"id": "magnet", "label": "Magnet Coil\n+40 magnet radius", "kind": "passive"},
	{"id": "max_hp", "label": "Plating\n+20 max HP + heal", "kind": "passive"},
	{"id": "xp_gain", "label": "Scavenger\n+1 bonus XP on gem", "kind": "passive"},
	{"id": "heal", "label": "Field Ration\nHeal 30 HP", "kind": "passive"},
]

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in buttons.size():
		var b := buttons[i]
		b.pressed.connect(_on_card_pressed.bind(i))

func set_loadout(owned_weapons: Array, weapon_count: int) -> void:
	_owned_weapons.clear()
	for w in owned_weapons:
		_owned_weapons.append(String(w))
	_weapon_count = weapon_count

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

func _eligible_cards() -> Array:
	var out: Array = []
	for card in CARD_DEFS:
		var kind := String(card.get("kind", "passive"))
		var wid := String(card.get("weapon", ""))
		if kind == "new_weapon":
			if wid != "" and wid in _owned_weapons:
				continue
			if _weapon_count >= MAX_WEAPONS:
				continue
		elif kind == "upgrade_weapon":
			if wid == "" or wid not in _owned_weapons:
				continue
		out.append(card)
	# Always keep at least passives
	if out.size() < 3:
		for card in CARD_DEFS:
			if String(card.get("kind", "")) == "passive" and card not in out:
				out.append(card)
	return out

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
	var picks: Array = _eligible_cards()
	picks.shuffle()
	while picks.size() < 3:
		picks.append({"id": "heal", "label": "Field Ration\nHeal 30 HP", "kind": "passive"})
	for i in buttons.size():
		var card: Dictionary = picks[i]
		# Map upgrade alias back to pulse_halo id for Run handler
		var cid := String(card["id"])
		if cid == "pulse_halo_up":
			cid = "pulse_halo"
		buttons[i].text = String(card["label"])
		buttons[i].set_meta("card_id", cid)
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
