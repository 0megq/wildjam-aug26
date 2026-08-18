extends Node

var current_aggro_points: int = 0 :
	set(value):
		current_aggro_points = value
		$Label.text = "aggro: %d" % current_aggro_points


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_story()

func load_story() -> void:
	var file := FileAccess.open("res://assets/Case1.json", FileAccess.READ)
	
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	for key in data:
		var dialog_data: Dictionary = data[key]
		var action: Action = Action.new()
		action.type = Action.Type.DIALOG
		action.id = "DIALOG_%02d" % int(key)
		action.text = dialog_data["text"]
		
		# TODO: continue writing this logic to assign the setters
		for setter in dialog_data["set"]:
			var value = dialog_data["set"][setter]
			match setter:
				"speaker":
					action.picture
				"background":
					pass
				"targetSprite":
					pass
				"bullSprite":
					pass
		# TODO: write logic for the link. if it's a "-->" then it's simple
		
		# Otherwise, create new option selects
