extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DialogueBox.dialog_finished.connect(_on_dialog_finished)
	$OptionPopup.option_selected.connect(_on_option_selected)
	$DialogueBox.text_display("hello")

	

func _on_dialog_finished() -> void:
	$OptionPopup.display_options(["hello", "you idiot"])
	
func _on_option_selected(number: int) -> void:
	print("option %d chosen" % number)
	$OptionPopup.hide()
	$DialogueBox.text_display("fuck off please")
