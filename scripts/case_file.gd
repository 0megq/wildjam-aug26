extends Control

signal case_file_selected

func _on_texture_button_pressed() -> void:
	print("case 1 selected")
	case_file_selected.emit()
