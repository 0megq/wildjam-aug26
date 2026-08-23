extends TextureRect

signal finished

@onready var primary: TextureRect = self
@onready var alternate: TextureRect = $Alternate

func _ready() -> void:
	set_background("black", 0)

func set_background(background: StringName, tweenTime := 1.0) -> void:
	var nextTexture: Texture = get_background_texture(background)
	var nextActive := alternate
	alternate.texture = nextTexture
	var tween := create_tween()
	tween.tween_property(alternate, "self_modulate", Color.WHITE, tweenTime)
	tween.parallel().tween_property(primary, "self_modulate", Color.TRANSPARENT, tweenTime)
	tween.tween_callback(finished.emit)
	alternate = primary
	primary = nextActive
	
	
func get_background_texture(background: StringName) -> Texture:
	var nextTexture: Texture
	match background:
		"black":
			pass
		"office":
			nextTexture = preload("res://assets/backgrounds/office.jpg")
		"doorOpen":
			nextTexture = preload("res://assets/backgrounds/outside_house_minigame.jpg")
		"doorClosed":
			nextTexture = preload("res://assets/backgrounds/street.jpg")
		"street":
			nextTexture = preload("res://assets/backgrounds/street.jpg")
		_:
			printerr("INVALID BACKGROUND: %s" % background)
	return nextTexture
			
		
