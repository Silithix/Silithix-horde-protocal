extends CanvasLayer
## Run HUD — portrait chrome (Art restyle on Systems bind API).

@onready var hp_label: Label = $Root/HpLabel
@onready var xp_label: Label = $Root/XpLabel
@onready var timer_label: Label = $Root/Timer
@onready var hp_fill: ColorRect = $Root/HpTrack/HpFill
@onready var hp_track: ColorRect = $Root/HpTrack
@onready var xp_fill: ColorRect = $Root/XpTrack/XpFill
@onready var xp_track: ColorRect = $Root/XpTrack

const COL_HP := Color(0.239, 1.0, 0.604)
const COL_HP_LOW := Color(1.0, 0.361, 0.424)
const COL_XP := Color(0.486, 1.0, 0.361)

var _elapsed: float = 0.0
var _running: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta: float) -> void:
	if not _running:
		return
	_elapsed += delta
	timer_label.text = _format_time(_elapsed)

func bind_player(player: Node) -> void:
	if player.has_signal("hp_changed"):
		player.connect("hp_changed", _on_hp)
	if player.has_signal("xp_changed"):
		player.connect("xp_changed", _on_xp)
	_on_hp(player.get("hp"), player.get("max_hp"))
	_on_xp(player.get("xp"), player.get("xp_to_next"), player.get("level"))

func stop() -> void:
	_running = false

func _on_hp(current: float, maximum: float) -> void:
	hp_label.text = "HP %d / %d" % [int(current), int(maximum)]
	var ratio := 0.0 if maximum <= 0.0 else clampf(float(current) / float(maximum), 0.0, 1.0)
	var w := hp_track.size.x if hp_track.size.x > 1.0 else 360.0
	hp_fill.offset_right = w * ratio
	hp_fill.offset_bottom = hp_track.size.y if hp_track.size.y > 1.0 else 24.0
	hp_fill.color = COL_HP_LOW if ratio <= 0.3 else COL_HP

func _on_xp(current: int, to_next: int, lvl: int) -> void:
	xp_label.text = "Lv %d  XP %d / %d" % [lvl, current, to_next]
	var ratio := 0.0 if to_next <= 0 else clampf(float(current) / float(to_next), 0.0, 1.0)
	var w := xp_track.size.x if xp_track.size.x > 1.0 else 1016.0
	xp_fill.offset_right = w * ratio
	xp_fill.offset_bottom = xp_track.size.y if xp_track.size.y > 1.0 else 12.0
	xp_fill.color = COL_XP

func _format_time(t: float) -> String:
	var s := int(t)
	return "%d:%02d" % [s / 60, s % 60]
