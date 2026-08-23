extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Story.background_changed.connect(_on_background_changed)
	hide()
	
func _on_background_changed(value: String) -> void:
	if value == "doorOpen":
		show()
	else:
		hide()
