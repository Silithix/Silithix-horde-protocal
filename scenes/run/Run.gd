extends Node2D
## Run root. Systems owns player/camera/XP/pooling/pause/crates/spawn mix.

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const XP_GEM_SCENE := preload("res://scenes/pickups/XpGem.tscn")
const CRATE_SCENE := preload("res://scenes/pickups/Crate.tscn")
const DRIFTER_SCENE := preload("res://scenes/enemies/Drifter.tscn")
const HOUND_SCENE := preload("res://scenes/enemies/Hound.tscn")
const TOX_SPOUT_SCENE := preload("res://scenes/enemies/ToxSpout.tscn")
const SHARD_KNIVES := preload("res://scenes/combat/ShardKnivesWeapon.tscn")
const PULSE_HALO := preload("res://scenes/combat/PulseHaloWeapon.tscn")
const LEVEL_UP_UI := preload("res://scenes/ui/LevelUpUI.tscn")
const PAUSE_MENU := preload("res://scenes/ui/PauseMenu.tscn")
const HUD_SCENE := preload("res://scenes/ui/RunHud.tscn")

const ENEMY_CAP := 28
const SPAWN_RADIUS := 560.0
const SPAWN_INTERVAL := 1.85
const INITIAL_DRIFTERS := 2
const CRATE_INTERVAL := 18.0
const TOX_UNLOCK_S := 60.0

@onready var world: Node2D = $World
@onready var entities: Node2D = $Entities
@onready var pickups: Node2D = $Pickups
@onready var ui_layer: CanvasLayer = $UI

var player: CharacterBody2D
var camera: Camera2D
var level_up_ui: CanvasLayer
var pause_menu: CanvasLayer
var hud: CanvasLayer
var _weapon: Node = null
var _halo: Node = null
var _spawn_timer: float = 0.0
var _crate_timer: float = 2.0
var _elapsed: float = 0.0
var _run_over: bool = false
var _bonus_xp_on_gem: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("run_root")
	add_to_group("run")
	if has_node("UI/StubLabel"):
		$UI/StubLabel.queue_free()

	Pool.warm(&"xp_gem", XP_GEM_SCENE, 64)
	Pool.warm(&"crate", CRATE_SCENE, 8)
	Pool.warm(&"drifter", DRIFTER_SCENE, 48)
	Pool.warm(&"hound", HOUND_SCENE, 32)
	Pool.warm(&"tox_spout", TOX_SPOUT_SCENE, 24)

	player = PLAYER_SCENE.instantiate()
	entities.add_child(player)
	player.global_position = Vector2(540, 960)
	player.died.connect(_on_player_died)
	player.leveled_up.connect(_on_player_leveled_up)

	_weapon = SHARD_KNIVES.instantiate()
	player.add_child(_weapon)
	_weapon.setup(player)

	camera = Camera2D.new()
	camera.set_script(load("res://scripts/player/FollowCamera.gd"))
	entities.add_child(camera)
	camera.call("set_target", player)
	camera.global_position = player.global_position

	level_up_ui = LEVEL_UP_UI.instantiate()
	add_child(level_up_ui)
	level_up_ui.card_picked.connect(_on_card_picked)

	pause_menu = PAUSE_MENU.instantiate()
	add_child(pause_menu)
	pause_menu.resume_pressed.connect(func(): pass)
	pause_menu.hub_pressed.connect(_abandon_to_hub)

	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.call("bind_player", player)

	for i in INITIAL_DRIFTERS:
		_spawn_enemy_key(&"drifter", DRIFTER_SCENE)
	_spawn_crate()

func _process(delta: float) -> void:
	if _run_over or get_tree().paused:
		return
	_elapsed += delta
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		if _alive_enemy_count() < ENEMY_CAP:
			_spawn_mixed()
	_crate_timer -= delta
	if _crate_timer <= 0.0:
		_crate_timer = CRATE_INTERVAL
		_spawn_crate()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if level_up_ui and level_up_ui.has_method("is_open") and level_up_ui.is_open():
		_abandon_to_hub()
		return
	if pause_menu and pause_menu.has_method("is_open") and pause_menu.is_open():
		pause_menu.close_menu(true)
		return
	if pause_menu:
		pause_menu.open_menu()

func _abandon_to_hub() -> void:
	if level_up_ui and level_up_ui.has_method("force_close"):
		level_up_ui.call("force_close")
	if pause_menu and pause_menu.has_method("close_menu"):
		pause_menu.call("close_menu", false)
	get_tree().paused = false
	Events.pause_toggled.emit(false)
	Game.go_to_hub()

func spawn_xp_gem(pos: Vector2, amount: int = 1) -> void:
	var tier := _roll_trash_gem_tier()
	var gem: Node = Pool.acquire(&"xp_gem", pickups)
	if gem == null:
		gem = XP_GEM_SCENE.instantiate()
		pickups.add_child(gem)
	var value := amount + _bonus_xp_on_gem
	if gem.has_method("setup"):
		if _bonus_xp_on_gem > 0:
			gem.call("setup", value, pos)
		else:
			gem.call("setup", 0, pos, tier)
	else:
		gem.global_position = pos

func vacuum_all_gems() -> void:
	if player == null:
		return
	for gem in get_tree().get_nodes_in_group("xp_gem"):
		if gem.has_method("magnet_pull") and gem.visible:
			gem.call("magnet_pull", player)

func _roll_trash_gem_tier() -> String:
	var roll := randi() % 100
	if roll < 8:
		return "blue"
	if roll < 28:
		return "large_green"
	return "small_green"

func _spawn_crate() -> void:
	if player == null or not is_instance_valid(player) or not player.alive:
		return
	var angle := randf() * TAU
	var pos := player.global_position + Vector2(cos(angle), sin(angle)) * randf_range(70.0, 140.0)
	var kinds := ["heal_meat", "magnet", "gold_bag"]
	var kind: String = kinds[randi() % kinds.size()]
	var crate: Node = Pool.acquire(&"crate", pickups)
	if crate == null:
		crate = CRATE_SCENE.instantiate()
		pickups.add_child(crate)
	if crate.has_method("setup"):
		crate.call("setup", pos, kind)

func _spawn_mixed() -> void:
	# Bulk Drifters; Hounds rare for first 90s (QA-B4); Tox Spouts after 1:00.
	var roll := randi() % 100
	var hound_chance := 8 if _elapsed < 90.0 else 28
	if _elapsed >= TOX_UNLOCK_S and roll < 18:
		_spawn_enemy_key(&"tox_spout", TOX_SPOUT_SCENE)
		return
	if roll < hound_chance:
		_spawn_enemy_key(&"hound", HOUND_SCENE)
	else:
		_spawn_enemy_key(&"drifter", DRIFTER_SCENE)

func _spawn_enemy_key(key: StringName, scene: PackedScene) -> void:
	if player == null or not is_instance_valid(player) or not player.alive:
		return
	var angle := randf() * TAU
	var radius := SPAWN_RADIUS
	if key == &"tox_spout":
		radius = SPAWN_RADIUS + 40.0
	var pos := player.global_position + Vector2(cos(angle), sin(angle)) * radius
	var enemy: Node = Pool.acquire(key, entities)
	if enemy == null:
		enemy = scene.instantiate()
		entities.add_child(enemy)
	if enemy.has_method("activate"):
		enemy.call("activate", pos, player)
	else:
		enemy.global_position = pos

func _alive_enemy_count() -> int:
	var n := 0
	for c in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(c) and c.visible and c.get_parent() == entities:
			n += 1
	return n

func _on_player_leveled_up(new_level: int) -> void:
	if pause_menu and pause_menu.has_method("close_menu"):
		pause_menu.call("close_menu", false)
	level_up_ui.show_level_up(new_level)

func _upgrade_starter_weapon() -> void:
	if _weapon == null or not is_instance_valid(_weapon):
		return
	var lv := int(_weapon.get("level")) if _weapon.get("level") != null else 1
	lv = mini(lv + 1, 5)
	if _weapon.has_method("set_level"):
		_weapon.call("set_level", lv)

func _offer_or_upgrade_pulse_halo() -> void:
	if _halo == null or not is_instance_valid(_halo):
		_halo = PULSE_HALO.instantiate()
		player.add_child(_halo)
		_halo.setup(player)
	elif _halo.has_method("set_level"):
		var lv := int(_halo.get("level")) if _halo.get("level") != null else 1
		_halo.call("set_level", mini(lv + 1, 5))

func _on_card_picked(card_id: String) -> void:
	match card_id:
		"shard_knives":
			_upgrade_starter_weapon()
		"pulse_halo":
			_offer_or_upgrade_pulse_halo()
		"move_speed":
			player.set_meta("speed_mult", float(player.get_meta("speed_mult", 1.0)) + 0.12)
		"magnet":
			player.set_magnet_radius(player.magnet_radius + 40.0)
		"max_hp":
			player.max_hp += 20.0
			player.heal(20.0)
		"xp_gain":
			_bonus_xp_on_gem += 1
		"heal":
			player.heal(30.0)

func _on_player_died() -> void:
	_run_over = true
	if level_up_ui and level_up_ui.has_method("force_close"):
		level_up_ui.call("force_close")
	if pause_menu and pause_menu.has_method("close_menu"):
		pause_menu.call("close_menu", false)
	get_tree().paused = false
	if hud and hud.has_method("stop"):
		hud.call("stop")
	await get_tree().create_timer(1.2, true, false, true).timeout
	Game.end_run(false)
