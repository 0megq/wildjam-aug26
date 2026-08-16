extends Control

signal dialog_finished

const dialog = [
	"Oh, great. Just what I needed today.",
	"You can fuck right off, okay cow?",
]

var newline_detected := false
var dialog_idx := 0



@onready var character_sound: AudioStreamPlayer = $CharacterSound
@onready var character_timer: Timer = $CharacterTimer
@onready var label: Label = self.find_child("Label")

func _ready() -> void:
	hide()
	

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#if dialog_idx >= dialog.size():
			#dialog_finished.emit()
			#hide()
		#text_display(dialog[dialog_idx])
		#dialog_idx += 1


func text_display(text: String) -> void:
	show()
	label.visible_characters = 0
	label.text = text
	
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
