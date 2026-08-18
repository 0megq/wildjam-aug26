class_name Main extends Control


var current_action: Action

@onready var dialogue_box: DialogBox = $DialogueBox
@onready var option_popup: ColorRect = $OptionPopup


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_action("DIALOG_01")


func _on_dialog_finished() -> void:
	# choose next action (dialog, option, or cutscene)
	var next_action_id: String = current_action.get_next_action_id.call()
	begin_action(next_action_id)


func _on_option_selected(number: int) -> void:
	option_popup.hide()
	
	# apply modifiers
	Story.current_aggro_points += current_action.options[number].aggro_points
	
	# choose next
	var next_action_id: String = current_action.get_next_action_id.call(number)
	begin_action(next_action_id)


func get_action(id: String) -> Action:
	var action: Action = Action.new()
	action.id = id
	# try to resolve using dict in story loader
	# otherwise use the match
	match id:
		"DIALOG_01":
			action.type = Action.Type.DIALOG
			action.text = "hello this is dialog 1"
			action.picture = DialogBox.GUY
			action.set_next_action("OPTION_01")
		"DIALOG_02":
			action.type = Action.Type.DIALOG
			action.text = "THIS DIOLOG 2WO"
			action.picture = null
			action.set_next_action("OPTION_01")
		"OPTION_01":
			action.type = Action.Type.OPTION_SELECT
			action.options = [
				Action.Option.new("dialog 1 please", 5),
				Action.Option.new("DIALOG 2 NOW", -2)
			]
			action.get_next_action_id = func(option_selected: int):
				match option_selected:
					0: return "DIALOG_01"
					1: return "DIALOG_02"
		
	
	assert(action.type != Action.Type.NULL, "Action type not set")
	return action


func begin_action(id: String) -> void:
	current_action = get_action(id)
	match current_action.type:
		Action.Type.DIALOG:
			dialogue_box.dialog_finished.connect(_on_dialog_finished, CONNECT_ONE_SHOT)
			dialogue_box.text_display(current_action.text, current_action.picture)
		Action.Type.OPTION_SELECT:
			option_popup.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)
			option_popup.display_options(current_action.get_option_names())
