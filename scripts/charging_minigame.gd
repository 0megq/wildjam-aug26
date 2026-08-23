extends Node2D

var aimed_at_target := false

var acc = Vector2.ZERO
var vel = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Set if mouse is hidden or not
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#Initialize reticle position
	$Reticle.position = get_global_mouse_position()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#Detect if player is intending to charge
	if Input.is_action_pressed("charging"):
		$Reticle/ProgressBar.visible = true
		$Reticle/ProgressBar.value += 0.5
	else:
		$Reticle/ProgressBar.visible = false
		$Reticle/ProgressBar.value = 0
	
	#Detect if player charges at a certain target or not
	if $Reticle/ProgressBar.value == 100 and aimed_at_target:
		print("You charge at the target")
	elif $Reticle/ProgressBar.value == 100:
		print("You charge at something other than the target")

func _physics_process(delta: float) -> void:
	#Acceleration of the reticle depends on how far current pos of reticle is away from mouse cursor
	var pos_diff: Vector2 = ($Reticle.position - get_global_mouse_position())
	acc = -pos_diff * 0.3
	
	#Velocity calculated from acceleration
	vel += acc * delta
	
	#Update reticle position
	$Reticle.position += vel * delta
	


func _on_target_area_entered(area: Area2D) -> void:
	print('Reticle is on target')
	aimed_at_target = true


func _on_target_area_exited(area: Area2D) -> void:
	aimed_at_target = false
	print('Reticle is no longer on target')
