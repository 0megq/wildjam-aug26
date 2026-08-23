extends Control

signal case_file_selected
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var background: ColorRect = $Background

func _ready() -> void:
	hide()
	background.modulate = Color.TRANSPARENT
	v_box_container.modulate = Color.TRANSPARENT

func begin() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(background, "modulate", Color.WHITE, 0.5)
	tween.tween_property(v_box_container, "modulate", Color.WHITE, 1)
	if !Story.charged_ending_achieved:
		$Background/PottedPlant.visible = false
	else:
		$Background/PottedPlant.visible = true
		
func end() -> void:
	var tween := create_tween()
	tween.tween_property(v_box_container, "modulate", Color.TRANSPARENT, 0.5)
	tween.parallel().tween_property(background, "modulate", Color.TRANSPARENT, 1)
	tween.tween_callback(hide)

func _on_button_pressed() -> void:
	case_file_selected.emit()
