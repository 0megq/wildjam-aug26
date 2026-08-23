extends CanvasLayer

signal resume_pressed


func _on_resume_pressed() -> void:
	resume_pressed.emit()


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on__master_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
