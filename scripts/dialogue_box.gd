class_name DialogBox extends Control

signal dialog_finished

const BULL := preload("res://icon.svg")
const GUY := preload("res://guy.png")

var should_wait_for_confirmation := false
var newline_detected := false
var dialog_done := false
var waiting_for_confirmation := false :
	set(value):
		waiting_for_confirmation = value
		$MarginContainer/WaitIcon.visible = value

@onready var character_sound: AudioStreamPlayer = $CharacterSound
@onready var character_timer: Timer = $CharacterTimer
@onready var label: RichTextLabel = find_child("Label")
@onready var icon: TextureRect = find_child("Icon")

func _ready() -> void:
	hide()


func action_display(action: Action) -> void:
	should_wait_for_confirmation = action.wait_for_confirmation
	var text := action.text
	if Story.speaker == "narrator":
		text = "[i]" + text + "[/i]"
	text_display(text)
	# set picture
	icon.texture = Story.get_speaker_icon()
	icon.visible = icon.texture != null


func text_display(text: String) -> void:
	show()
	label.visible_characters = 0
	label.text = text
	
	label.visible_characters += 1
	character_sound.play()
	character_timer.start(0.05)		


func wait_or_emit_finished() -> void:
	if !should_wait_for_confirmation:
		dialog_finished.emit()
		return
	
	waiting_for_confirmation = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and waiting_for_confirmation:
		dialog_finished.emit()
		waiting_for_confirmation = false


func _on_character_timer_timeout() -> void:

	if label.visible_characters >= label.text.length():
		wait_or_emit_finished()
		return
	if newline_detected:
		label.text = label.text.substr(label.visible_characters + 1)
		label.visible_characters = 0
		newline_detected = false
	
	if label.text[label.visible_characters] == '\n':
		newline_detected = true
		character_timer.start(1)
	else:
		label.visible_characters += 1
		character_sound.play()
		character_timer.start(0.01)
