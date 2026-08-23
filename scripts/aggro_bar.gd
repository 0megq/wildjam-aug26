extends TextureProgressBar

@export var frame_normal: Texture2D
@export var frame_charged: Texture2D
@export var frame_hover: Texture2D

@export var charge_threshold: float = 0.8

signal charge_threshold_reached

var is_hovered := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_frame()

#TEST
#func _process(delta: float) -> void:
#	if Input.is_action_just_pressed("charging"):
#		value += 5

func _on_mouse_entered() -> void:
	is_hovered = true
	_update_frame()

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_frame()

func _on_value_changed(_new_value: float) -> void:
	_update_frame()

func _update_frame() -> void:
	if is_hovered:
		texture_over = frame_hover
	elif (value / max_value) >= charge_threshold:
		texture_over = frame_charged
		charge_threshold_reached.emit()
	else:
		texture_over = frame_normal
