extends TextureProgressBar

@export var frame_normal: Texture2D
@export var frame_charged: Texture2D
@export var frame_hover: Texture2D

@export var charge_threshold: float = 0.8

signal clicked

var is_hovered := false

func _ready() -> void:
	hide()
	$Polygon2D.hide()
	$AnimationPlayer.play("shake_arrow")
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_frame()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click") and is_hovered:
		clicked.emit()

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_frame()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_frame()

func _on_value_changed(_new_value: float) -> void:
	_update_frame()

func _update_frame() -> void:
	if (value / max_value) >= charge_threshold:
		$Polygon2D.show()
		tooltip_text = "Ready to charge!"
		if is_hovered:
			texture_over = frame_hover
		else:
			texture_over = frame_charged
	else:
		$Polygon2D.hide()
		tooltip_text = "Not ready to charge"
		texture_over = frame_normal
