class_name Action

enum Type {
	NULL,
	DIALOG,
	OPTION_SELECT,
	OTHER,
}

class Option:
	var text: String
	var aggro_points: int
	
	func _init(text0: String, aggro_points0: int  = 0) -> void:
		text = text0
		aggro_points = aggro_points0

var id: StringName
var type: Type
var get_next_action_id: Callable

## only makes sense when type is dialog
var text: String
## maps the variable name (from twine) to the string value
var setter_list: Dictionary

## only makes sense when type is OptionSelect
var options: Array[Option]

func set_next_action(id: StringName) -> void:
	get_next_action_id = func(): return id
	
func get_option_names() -> Array[String]:
	var res: Array[String]
	for option in options:
		res.append(option.text)
	return res
