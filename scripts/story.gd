extends Node

#add ending achieved indicators for the potted plant
var peaceful_ending_achieved := false
var charged_ending_achieved := false

signal aggro_points_changed(value: int)
signal background_changed(value: int)

var current_option_id: int = 1

var current_aggro_points: int = 0 :
	set(value):
		current_aggro_points = clampi(value, 0, 100)
		aggro_points_changed.emit(current_aggro_points)

var action_data: Dictionary[StringName, Action]

var bull_sprite: StringName = "neutral"
var target_sprite: StringName = "neutral"
var speaker: StringName = "narrator"
var background: StringName = "background" :
	set(value):
		background = value
		background_changed.emit(value)
var tween_time: float = 1.0

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
			if link_data[link].contains("Ending"):
				next = "ENDING_%d" % int(link_data[link])
			if (link == "-->"):
				action.set_next_action(next)
				action.wait_for_confirmation = true
				break
			options[Action.Option.new(link)] = next

		# setup the option action and its callback
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
		
	add_other_actions(res)
	
	#res["DIALOG_01"].setter_list["background"] = "black"
	res["DIALOG_02"].setter_list["background"] = "street"
	
	action_data = res
	
func add_other_actions(input: Dictionary[StringName, Action]) -> void:
	var action := Action.new()
	action.id = "ENDING_1"
	action.type = Action.Type.OTHER
	input[action.id] = action
	
	action = Action.new()
	action.id = "ENDING_2"
	action.type = Action.Type.OTHER
	input[action.id] = action
	
	action = Action.new()
	action.id = "ENDING_2_COMPLETE"
	action.type = Action.Type.OTHER
	input[action.id] = action
	
	action = Action.new()
	action.id = "ENDING_3"
	action.type = Action.Type.OTHER
	input[action.id] = action
	
	action = Action.new()
	action.id = "CASE_FILES"
	action.type = Action.Type.OTHER
	action.set_next_action("START_STORY")
	input[action.id] = action
	
	action = Action.new()
	action.id = "START_STORY"
	action.type = Action.Type.OTHER
	action.set_next_action("DIALOG_01")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_START"
	action.type = Action.Type.OTHER
	action.set_next_action("OFFICE_END")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_END"
	action.type = Action.Type.OTHER
	action.set_next_action("CASE_FILES")
	input[action.id] = action
	
	action = Action.new()
	action.id = "SPLASH_BEGIN"
	action.type = Action.Type.OTHER
	input[action.id] = action
	
	action = Action.new()
	action.id = "SPLASH_DIALOG"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "[i]It is another day at work in the Holstein Collections Inc. office. You are the proud leader of a truly noble department, venturing forth and claiming what is rightfully owed from those who would see it forever withheld.[/i]"
	action.set_next_action("OFFICE_START")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_01"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "[i]That is, you collect defaulted debts on behalf of the Hereford County Energy Department. And if those you seek should refuse, you ensure they are punished with gratuitous physical violence.[/i]"
	action.set_next_action("OFFICE_02")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_02"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "[i]In other words, you are a bull in charge of charging at people charged with not paying their charges for charging.[/i]"
	action.set_next_action("OFFICE_03")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_03"
	action.type = Action.Type.DIALOG
	action.text = "[i]Today’s case files are on your desk. Take a look?[/i]"
	action.set_next_action("OFFICE_OPTIONS")
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_OPTIONS"
	action.type = Action.Type.OPTION_SELECT
	action.options = [Action.Option.new("Yes"), Action.Option.new("No")]
	action.get_next_action_id = func(number: int):
		match number:
			0: return "CASE_FILES"
			1: return "OFFICE_04"
	input[action.id] = action
	
	action = Action.new()
	action.id = "OFFICE_04"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "[i]There is no escape for those in debt, nor for those under an employment contract. Do your job.[/i]"
	action.set_next_action("CASE_FILES")
	input[action.id] = action
	
	action = Action.new()
	action.id = "END_DIALOG"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "[i]You head back to the office.[/i]"
	action.setter_list["background"] = "black"
	action.set_next_action("DRIVING_BACK")
	input[action.id] = action
	
	action = Action.new()
	action.id = "DRIVING_BACK"
	action.type = Action.Type.OTHER
	action.set_next_action("CASE_FILES")
	input[action.id] = action
	


## DON't CALL THIS IN THE FINAL BUILD
func add_dummy(input) -> void:
	var action := Action.new()
	action.id = "DUMMY_DELETE_ME"
	action.type = Action.Type.DIALOG
	action.wait_for_confirmation = true
	action.text = "ENFNJHFNJAFN"
	action.setter_list["background"] = "doorOpen"
	action.set_next_action("ENDING_3")
	input[action.id] = action


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
				tween_time = 1.0
				background = value
			"agitation":
				if value.contains("it"):
					var numberStr := value.substr(2).remove_chars(" ")
					var number := int(numberStr)
					current_aggro_points += number
				else:
					current_aggro_points = int(value)
			_:
				printerr("unmatched variable in setter list \"%s\" with value \"%s\"" % [variable, value])

func get_speaker_icon() -> Texture:
	match speaker:
		"bull":
			return load("res://assets/pictures/%s_%s.png" % [speaker, bull_sprite])
		"target":
			return load("res://assets/pictures/%s_%s.png" % [speaker, target_sprite])
		_:
			return null
