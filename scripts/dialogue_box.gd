class_name DialogBox extends Control

signal dialog_finished

const BULL := preload("res://icon.svg")
const GUY := preload("res://guy.png")


var newline_detected := false
var dialog_idx := 0

@onready var character_sound: AudioStreamPlayer = $CharacterSound
@onready var character_timer: Timer = $CharacterTimer
@onready var label: Label = find_child("Label")
@onready var icon: TextureRect = find_child("Icon")

func _ready() -> void:
	hide()


func text_display(text: String, picture: Texture) -> void:
	show()
	label.visible_characters = 0
	label.text = text
	icon.visible = picture != null
	icon.texture = picture
	
	label.visible_characters += 1
	character_sound.play()
	character_timer.start(0.05)		


func _on_character_timer_timeout() -> void:

	if label.visible_characters >= label.text.length():
		dialog_finished.emit()
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
		character_timer.start(0.05)
