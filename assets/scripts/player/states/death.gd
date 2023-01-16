extends PlayerState

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var volume_linear: float = 0.0:
	get:
		return volume_linear
	set(value):
		volume_linear = value
		audio.volume_db = linear_to_db(value)


func enter(_msg := {}) -> void:
	EventBus.player_death.emit()
	audio.play()
	var tween = create_tween()
	tween.tween_property(self, "volume_linear", 1.0, 3.0)
