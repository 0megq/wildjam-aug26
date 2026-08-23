class_name DialogBox extends Control

signal dialog_finished

const BULL := preload("res://icon.svg")
const GUY := preload("res://guy.png")

var should_wait_for_confirmation := false
var dialog_done := false
var waiting_for_confirmation := false :
	set(value):
		waiting_for_confirmation = value
		wait_icon.visible = value

@onready var character_sound: AudioStreamPlayer = find_child("CharacterSound")
@onready var character_timer: Timer = find_child("CharacterTimer")
@onready var label: RichTextLabel = find_child("Label")
@onready var icon: TextureRect = find_child("Icon")
@onready var wait_icon: Control = find_child("WaitIcon")

func _ready() -> void:
	hide()


func action_display(action: Action) -> void:
	wait_icon.hide()
	should_wait_for_confirmation = action.wait_for_confirmation
	var text := action.text
	if Story.speaker == "narrator":
		text = "[color=gold]" + text + "[/color]"
	text_display(text)
	# set picture
	icon.texture = Story.get_speaker_icon()
	icon.visible = icon.texture != null


func text_display(text: String) -> void:
	show()
	label.text = text
	label.visible_characters = 0
	
	label.visible_characters += 1
	character_sound.play()
	character_timer.start(0.05)		


func wait_or_emit_finished() -> void:
	if !should_wait_for_confirmation:
		dialog_finished.emit()
		return
	
	waiting_for_confirmation = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_dialogue"):
		label.visible_characters = label.text.length()
		if waiting_for_confirmation:
			dialog_finished.emit()
			waiting_for_confirmation = false

func reset() -> void:
	hide()
	label.text = ""
	character_timer.stop()

func _on_character_timer_timeout() -> void:
	if label.visible_characters >= label.text.length():
		wait_or_emit_finished()
		character_timer.stop()
		return
	
	label.visible_characters += 1
	if randf() > 0.7:
		character_sound.play()
	character_timer.start(0.01)

#func get_text_real_start() -> int:
	#var text := label.text
	#var tagCount := text.count("/")
	#var curIdx := 0
	#while tagCount > 0:
		#curIdx = text.find("]", curIdx) + 1
		#tagCount -= 1
	#return curIdx
	
#func get_text_real_end() -> int:
	#var text := label.text
	#var tagCount := text.count("/")
	#var curIdx := 0
	#
	#while tagCount > 0:
		#curIdx = text.rfind("[", curIdx) - 1
		#tagCount -= 1
	#return curIdx
