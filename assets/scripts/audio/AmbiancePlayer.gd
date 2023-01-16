extends Node

@export var audio_stream: AudioStream
@export_range(0, 1, 0.01) var normal_volume: float

@export var normal_fade_duration: float

@onready var _player: AudioStreamPlayer = $AudioStreamPlayer

var _tween: Tween
var _volume_linear: float:
	set(value):
		_player.volume_db = linear_to_db(value)
		_volume_linear = value
	get:
		return _volume_linear


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player.stream = audio_stream
	_player.volume_db = linear_to_db(0)
	EventBus.gate_status.connect(_gate_status)
	EventBus.player_leaving.connect(_player_leaving)


func _gate_status(status: bool) -> void:
	if _player.playing or status:
		return
	
	_player.play()
	_tween_to(normal_volume, normal_fade_duration)


func _player_leaving() -> void:
	_tween_to(0, normal_fade_duration)
	await _tween.finished
	_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _tween_to(volume: float, duration: float) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "_volume_linear", volume, duration)
