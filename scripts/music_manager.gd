extends AudioStreamPlayer

@onready var active_player: AudioStreamPlayer = self

func _ready() -> void:
	Story.aggro_points_changed.connect(_on_aggro_points_changed)

func fade_in_music(duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(active_player, "volume_db", 0, duration)

func fade_out_music(duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(active_player, "volume_db", -80, duration)

func _on_aggro_points_changed(current_aggro_points: int):
	pitch_scale = 1 + (current_aggro_points/100 * 1.5)
