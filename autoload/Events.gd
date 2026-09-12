extends Node
## Central signal bus. No gameplay logic.
## Systems/Combat/Waves emit and listen here.

signal run_started
signal run_ended(won: bool)
signal player_damaged(amount: float, source: Node)
signal player_died
signal player_leveled_up(new_level: int)
signal xp_gained(amount: int)
signal enemy_killed(enemy: Node, gold: int)
signal pause_toggled(paused: bool)
signal chapter_phase_changed(phase_id: String)
signal boss_warning(boss_id: String)
signal chest_opened(rewards: Array)
signal settings_changed
