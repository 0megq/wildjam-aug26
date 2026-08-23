extends TextureRect

signal finished


var waiting := false

func _ready() -> void:
	hide()
	$Label.modulate = Color.TRANSPARENT
	modulate = Color.TRANSPARENT

func begin() -> void:
	show()
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.5)
	tween.tween_property($Label, "modulate", Color.WHITE, 0.1)
	tween.tween_callback(start_waiting_for_enter)
	
func end() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 2)
	tween.tween_callback(hide)
	
func start_waiting_for_enter() -> void:
	waiting = true

func _input(event: InputEvent) -> void:
	if waiting and event.is_action_pressed("next_dialogue"):
		waiting = false
		get_viewport().set_input_as_handled()
		$Label.hide()
		finished.emit()
		
