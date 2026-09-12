extends Node
## App / run state shell. Systems fills run loop details.

enum AppState { BOOT, HUB, RUN, RESULTS }

var state: AppState = AppState.BOOT
var run_seed: int = 0

func _ready() -> void:
	pass

func go_to_hub() -> void:
	state = AppState.HUB
	get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")

func start_run(seed_override: int = 0) -> void:
	run_seed = seed_override if seed_override != 0 else randi()
	state = AppState.RUN
	Events.run_started.emit()
	get_tree().change_scene_to_file("res://scenes/run/Run.tscn")

func end_run(won: bool) -> void:
	state = AppState.RESULTS
	Events.run_ended.emit(won)
	# Milestone A: return to hub; Results scene comes later
	go_to_hub()
