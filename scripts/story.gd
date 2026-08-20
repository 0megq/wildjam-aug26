extends Node

signal aggro_points_changed(value: int)

var current_option_id: int = 1

var current_aggro_points: int = 0 :
	set(value):
		current_aggro_points = value
		aggro_points_changed.emit(value)

var action_data: Dictionary[StringName, Action]

var bull_sprite: StringName = "neutral"
var target_sprite: StringName = "neutral"
var speaker: StringName = "narrator"
var background: StringName = "background"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_story()

func load_story() -> void:
	var file := FileAccess.open("res://assets/Case1.json", FileAccess.READ)
	
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	var res: Dictionary[StringName, Action]
	
	for key in data:
		var dialog_data: Dictionary = data[key]
		var action: Action = Action.new()
		action.type = Action.Type.DIALOG
		action.id = "DIALOG_%02d" % int(key)
		action.text = dialog_data["text"]
		
		action.setter_list = dialog_data["set"]
		
		var link_data: Dictionary = dialog_data["link"]
		if link_data.size() == 0:
			action.set_next_action("")
		
		var options: Dictionary[Action.Option, StringName]		
		for link in link_data:
			var next: StringName = "DIALOG_%02d" % int(link_data[link])
			if (link == "-->"):
				action.set_next_action(next)
				action.wait_for_confirmation = true
				break
			options[Action.Option.new(link, 0)] = next
			
		if options.size() > 0:
			var option_action := Action.new()
			option_action.type = Action.Type.OPTION_SELECT
			option_action.id = "OPTION_%02d" % current_option_id
			option_action.get_next_action_id = func(number: int):
				for i in options.size():
					if i == number:
						return options.values()[i]
			option_action.options = options.keys()
			
			action.set_next_action(option_action.id)
			res[option_action.id] = option_action
			current_option_id += 1
		
		# Otherwise, create new option selects using link name and go to
		res[action.id] = action
		
	action_data = res


func apply_setter_list(list: Dictionary) -> void:
	for variable in list:
		var value: StringName = list[variable]
		match variable:
			"bullSprite":
				bull_sprite = value
			"targetSprite":
				target_sprite = value
			"speaker":
				speaker = value
			"background":
				background = value
			_:
				printerr("unmatched variable in setter list \"%s\" with value \"%s\"" % [variable, value])

func get_speaker_icon() -> Texture:
	match speaker:
		"bullerton":
			return load("%s_%s.png" % [speaker, bull_sprite])
		"target":
			return load("%s_%s.png" % [speaker, target_sprite])
		_:
			return null
