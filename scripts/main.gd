class_name Main extends Control


var current_action: Action

#var cutscene_playing := false #make this into a global var
var paused := false :
	set(value):
		#if cutscene_playing:
		#	value = fals
		paused = value
		pause_menu.visible = value

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var dialogue_box: DialogBox = $DialogueBox
@onready var option_popup: ColorRect = $OptionPopup

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Story.aggro_points_changed.connect(func(value: int): $Label.text = "AP: %2d" % value)
	begin_action("DIALOG_01")

func _on_dialog_finished() -> void:
	# choose next action (dialog, option, or cutscene)
	var next_action_id: StringName = current_action.get_next_action_id.call()
	begin_action(next_action_id)


func _on_option_selected(number: int) -> void:
	option_popup.hide()
	
	# apply modifiers
	Story.current_aggro_points += current_action.options[number].aggro_points
	
	# choose next
	var next_action_id: StringName = current_action.get_next_action_id.call(number)
	begin_action(next_action_id)


func get_action(id: StringName) -> Action:
	var action: Action
	if Story.action_data.has(id):
		action = Story.action_data[id]
	
	return action


func begin_action(id: StringName) -> void:
	current_action = get_action(id)
	if !current_action:
		printerr("not a valid action id!")
		return
	match current_action.type:
		Action.Type.DIALOG:
			# Setters must be applied before we begin dialog, otherwise the picture will not be up-to-date
			Story.apply_setter_list(current_action.setter_list)
			
			dialogue_box.dialog_finished.connect(_on_dialog_finished, CONNECT_ONE_SHOT)
			dialogue_box.action_display(current_action)
		Action.Type.OPTION_SELECT:
			option_popup.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)
			option_popup.display_options(current_action.get_option_names())
	
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused

func _on_pause_menu_resume_pressed() -> void:
	paused = false
