extends Node
## Thin audio facade. Art owns actual streams; wire them later.

func play_sfx(_id: String) -> void:
	pass

func play_music(_id: String) -> void:
	pass

func stop_music() -> void:
	pass

func set_music_enabled(on: bool) -> void:
	Save.data["settings"]["music"] = on
	Save.save_game()
	Events.settings_changed.emit()

func set_sfx_enabled(on: bool) -> void:
	Save.data["settings"]["sfx"] = on
	Save.save_game()
	Events.settings_changed.emit()
