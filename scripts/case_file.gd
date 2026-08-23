extends Control

signal case_file_selected

func _ready() -> void:
	if !Story.charged_ending_achieved:
		$Background/PottedPlant.visible = false
	else:
		$Background/PottedPlant.visible = true

func _on_texture_button_pressed() -> void:
	print("case 1 selected")
	case_file_selected.emit()
