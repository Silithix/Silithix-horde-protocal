extends Node
## Lightweight chapter phase clock for Milestone B opener.
## Waves can later replace phases with authored JSON; Systems owns the clock.

signal phase_changed(phase_id: String)

const OPENER_END_S := 120.0

## phase_id -> start time (seconds)
const PHASES := [
	{"id": "opener_calm", "at": 0.0},
	{"id": "opener_pressure", "at": 45.0},
	{"id": "opener_mix", "at": 90.0},
	{"id": "opener_done", "at": OPENER_END_S},
]

var elapsed: float = 0.0
var _phase_index: int = 0
var _running: bool = false

func start() -> void:
	elapsed = 0.0
	_phase_index = 0
	_running = true
	_emit_phase(String(PHASES[0]["id"]))

func stop() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running:
		return
	elapsed += delta
	while _phase_index + 1 < PHASES.size() and elapsed >= float(PHASES[_phase_index + 1]["at"]):
		_phase_index += 1
		_emit_phase(String(PHASES[_phase_index]["id"]))

func current_phase_id() -> String:
	return String(PHASES[_phase_index]["id"])

func _emit_phase(phase_id: String) -> void:
	phase_changed.emit(phase_id)
	Events.chapter_phase_changed.emit(phase_id)
