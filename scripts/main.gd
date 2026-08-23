class_name Main extends Control


var current_action: Action

var paused := false :
	set(value):
		paused = value
		pause_menu.visible = value

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var dialogue_box: DialogBox = $DialogueBox
@onready var option_popup: ColorRect = $OptionPopup
@onready var aggro_points: TextureProgressBar = $AggroBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Story.aggro_points_changed.connect(func(value: int): 
		aggro_points.value = value
		aggro_points.show()
	)
	Story.background_changed.connect(func(value:StringName):
		background.set_background(value, Story.tween_time)
	)
	Story.target_changed.connect(func(value: StringName):
		$FishSprite.texture = load("res://assets/pictures/fish_%s.png" % value)
	)
	begin_action("SPLASH_BEGIN")
	$ChargingMinigame.set_process(false)
	

func _on_dialog_finished() -> void:
	# choose next action (dialog, option, or cutscene)
	var next_action_id: StringName = current_action.get_next_action_id.call()
	begin_action(next_action_id)


func _on_option_selected(number: int) -> void:
	option_popup.hide()
	
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
			
			if current_action.id == "DIALOG_05":
				$BellSound.play()
		Action.Type.OPTION_SELECT:
			option_popup.option_selected.connect(_on_option_selected, CONNECT_ONE_SHOT)
			option_popup.display_options(current_action.get_option_names())
		Action.Type.OTHER:
			match current_action.id:
				"SPLASH_BEGIN":
					$Splash.begin()
					$Splash.finished.connect(begin_action.bind("SPLASH_DIALOG"))
					animation_player.play("show_black_instant")
				"OFFICE_START":
					$Splash.end()
					$DialogueBox.hide()
					Story.tween_time = 2.0
					Story.background = "office"
					background.finished.connect(_splash_to_office_done, CONNECT_ONE_SHOT)
				"CASE_FILES":
					$DialogueBox.hide()
					$CaseFile.begin()
					Story.background = "office"
					$CaseFile.case_file_selected.connect(_on_case_file_selected)
				"START_STORY":
					Story.tween_time = 1.0
					Story.background = "black"
					get_tree().create_timer(2).timeout.connect($CarSound.play)
					get_tree().create_timer(4).timeout.connect(_on_story_start_ready)
				"ENDING_1":
					$VictorySound.play()
					$DialogueBox.hide()
					Story.background = "ending1"
					do_ending_transition()
				"ENDING_2":
					begin_action.call_deferred("ENDING_2_COMPLETE")
				"ENDING_2_COMPLETE":
					$VictorySound.play()
					$DialogueBox.hide()
					Story.background = "ending2"
					do_ending_transition()
				"ENDING_3":
					$VictorySound.play()
					$DialogueBox.hide()
					Story.background = "ending3"
					do_ending_transition()
				"DRIVING_BACK":
					$DialogueBox.hide()
					$CarSound.play()
					await get_tree().create_timer(3).timeout
					begin_action.call_deferred("CASE_FILES")
					

func do_ending_transition() -> void:
	await get_tree().create_timer(5).timeout
	begin_action.call_deferred("END_DIALOG")
	

func _on_story_start_ready() -> void:
	# PLAY DRIVING SOUND
	await get_tree().create_timer(0.5).timeout
	begin_action.call_deferred("DIALOG_01")


func _on_case_file_selected() -> void:
	$CaseFile.end()
	begin_action.call_deferred("START_STORY")

func _splash_to_office_done() -> void:
	begin_action.call_deferred("OFFICE_01")

	
func _input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		paused = !paused

func _on_pause_menu_resume_pressed() -> void:
	paused = false
