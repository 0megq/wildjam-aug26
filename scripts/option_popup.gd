extends ColorRect

signal option_selected(number: int)

@onready var option_container = $OptionContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in option_container.get_child_count():
		option_container.get_child(i).pressed.connect(_on_option_selected.bind(i+1))


func _on_option_selected(number: int) -> void:
	option_selected.emit(number)


func display_options(arr: Array):
	for child in option_container.get_children():
		child.hide()
	show()
	for i in arr.size():
		var option := option_container.get_child(i)
		option.show()
		option.text = arr[i]
