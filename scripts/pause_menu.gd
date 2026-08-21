extends CanvasLayer

signal resume_pressed


func _on_resume_pressed() -> void:
	resume_pressed.emit()


func _on_quit_pressed() -> void:
	get_tree().quit()
