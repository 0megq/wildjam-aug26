extends Control

signal case_file_selected

func _on_texture_button_pressed() -> void:
	case_file_selected.emit()
