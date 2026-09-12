extends Node2D
## Run root. Systems owns player/camera/XP/pooling/damage path here.

const PLAYER_SCENE := preload("res://scenes/player/Player.tscn")
const XP_GEM_SCENE := preload("res://scenes/pickups/XpGem.tscn")
const DRIFTER_SCENE := preload("res://scenes/enemies/Drifter.tscn")
const SHARD_KNIVES := preload("res://scenes/combat/ShardKnivesWeapon.tscn")
const LEVEL_UP_UI := preload("res://scenes/ui/LevelUpUI.tscn")
const HUD_SCENE := preload("res://scenes/ui/RunHud.tscn")

const ENEMY_CAP := 24
const SPAWN_RADIUS := 560.0
const SPAWN_INTERVAL := 2.0
const INITIAL_DRIFTERS := 2

@onready var world: Node2D = $World
@onready var entities: Node2D = $Entities
@onready var pickups: Node2D = $Pickups
@onready var ui_layer: CanvasLayer = $UI

var player: CharacterBody2D
var camera: Camera2D
var level_up_ui: CanvasLayer
var hud: CanvasLayer
var _spawn_timer: float = 0.0
var _run_over: bool = false
var _bonus_xp_on_gem: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("run_root")
	add_to_group("run")
	if has_node("UI/StubLabel"):
		$UI/StubLabel.queue_free()

	Pool.warm(&"xp_gem", XP_GEM_SCENE, 64)
	Pool.warm(&"drifter", DRIFTER_SCENE, 64)

	player = PLAYER_SCENE.instantiate()
	entities.add_child(player)
	player.global_position = Vector2(540, 960)
	player.died.connect(_on_player_died)
	player.leveled_up.connect(_on_player_leveled_up)

	var wpn := SHARD_KNIVES.instantiate()
	player.add_child(wpn)
	wpn.setup(player)

	camera = Camera2D.new()
	camera.set_script(load("res://scripts/player/FollowCamera.gd"))
	entities.add_child(camera)
	camera.call("set_target", player)
	camera.global_position = player.global_position

	level_up_ui = LEVEL_UP_UI.instantiate()
	add_child(level_up_ui)
	level_up_ui.card_picked.connect(_on_card_picked)

	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.call("bind_player", player)

	for i in INITIAL_DRIFTERS:
		_spawn_drifter()

func _process(delta: float) -> void:
	if _run_over or get_tree().paused:
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		if _alive_enemy_count() < ENEMY_CAP:
			_spawn_drifter()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_abandon_to_hub()

func _abandon_to_hub() -> void:
	if level_up_ui and level_up_ui.has_method("force_close"):
		level_up_ui.call("force_close")
	else:
		get_tree().paused = false
		Events.pause_toggled.emit(false)
	Game.go_to_hub()

func spawn_xp_gem(pos: Vector2, amount: int = 1) -> void:
	var gem: Node = Pool.acquire(&"xp_gem", pickups)
	if gem == null:
		gem = XP_GEM_SCENE.instantiate()
		pickups.add_child(gem)
	var value := amount + _bonus_xp_on_gem
	if gem.has_method("setup"):
		gem.call("setup", value, pos)
	else:
		gem.global_position = pos

func _spawn_drifter() -> void:
	if player == null or not is_instance_valid(player) or not player.alive:
		return
	var angle := randf() * TAU
	var pos := player.global_position + Vector2(cos(angle), sin(angle)) * SPAWN_RADIUS
	var enemy: Node = Pool.acquire(&"drifter", entities)
	if enemy == null:
		enemy = DRIFTER_SCENE.instantiate()
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
	level_up_ui.show_level_up(new_level)

func _on_card_picked(card_id: String) -> void:
	match card_id:
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
	get_tree().paused = false
	if hud and hud.has_method("stop"):
		hud.call("stop")
	# ignore_pause so death delay still fires if something re-pauses
	await get_tree().create_timer(1.2, true, false, true).timeout
	Game.end_run(false)
