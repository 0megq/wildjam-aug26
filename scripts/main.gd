extends Control

enum ActionType {
	NULL,
	DIALOG,
	OPTION_SELECT,
	OTHER,
}

enum ActionId {
	DIALOG_01,
	DIALOG_02,
	OPTION_01
}

class Action:
	var id: ActionId
	var type: ActionType
	var get_next_action_id: Callable
	
	## only makes sense when type is dialog
	var text: String
	var picture: Texture
	var background: int
	
	## only makes sense when type is OptionSelect
	var options: Array[Option]
	
	func set_next_action(id: ActionId) -> void:
		get_next_action_id = func(): return id
		
	func get_option_names() -> Array[String]:
		var res: Array[String]
		for option in options:
			res.append(option.text)
		return res

class Option:
	var text: String
	var aggro_points: int
	
	func _init(text0: String, aggro_points0: int  = 0) -> void:
		text = text0
		aggro_points = aggro_points0

var current_aggro_points: int = 0 :
	set(value):
		current_aggro_points = value
		$Label.text = "aggro: %d" % current_aggro_points


var current_action: Action

@onready var dialogue_box: DialogBox = $DialogueBox
@onready var option_popup: ColorRect = $OptionPopup


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_action(ActionId.DIALOG_01)


func _on_dialog_finished() -> void:
	# choose next action (dialog, option, or cutscene)
	var next_action_id: ActionId = current_action.get_next_action_id.call()
	begin_action(next_action_id)


func _on_option_selected(number: int) -> void:
	option_popup.hide()
	
	# apply modifiers
	current_aggro_points += current_action.options[number].aggro_points
	
	# choose next
	var next_action_id: ActionId = current_action.get_next_action_id.call(number)
	begin_action(next_action_id)


func get_action(id: ActionId) -> Action:
	var action: Action = Action.new()
	action.id = id
	match id:
		ActionId.DIALOG_01:
			action.type = ActionType.DIALOG
			action.text = "hello this is dialog 1"
			action.picture = DialogBox.GUY
			action.set_next_action(ActionId.OPTION_01)
		ActionId.DIALOG_02:
			action.type = ActionType.DIALOG
			action.text = "THIS DIOLOG 2WO"
			action.picture = null
			action.set_next_action(ActionId.OPTION_01)
		ActionId.OPTION_01:
			action.type = ActionType.OPTION_SELECT
			action.options = [
				Option.new("dialog 1 please", 5),
				Option.new("DIALOG 2 NOW", -2)
			]
			action.get_next_action_id = func(option_selected: int):
				match option_selected:
					0: return ActionId.DIALOG_01
					1: return ActionId.DIALOG_02
					
	assert(action.type != ActionType.NULL, "Action type not set")
	return action


func begin_action(id: ActionId) -> void:
	current_action = get_action(id)
	match current_action.type:
		ActionType.DIALOG:
			dialogue_box.dialog_finished.connect(_on_dialog_finished, CONNECT_ONE_SHOT)
			dialogue_box.text_display(current_action.text, current_action.picture)
		ActionType.OPTION_SELECT:
			option_popup.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)
			option_popup.display_options(current_action.get_option_names())
