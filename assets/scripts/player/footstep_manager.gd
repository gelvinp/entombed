extends Node

@export_range(0.1, 1, 0.05) var slowest_delay = 0.1
@export_range(0.1, 1, 0.05) var fastest_delay = 0.1
@export_range(0.1, 1, 0.05) var quietest_volume = 0.1
@export_range(0.1, 1, 0.05) var loudest_volume = 0.1
@export_range(0.0, 1, 0.05) var biggest_room = 0.1
@export_range(0.0, 1, 0.05) var smallest_room = 0.1

@onready var player = owner as Player
@onready var left: AudioStreamPlayer = $LeftFoot
@onready var right: AudioStreamPlayer = $RightFoot
@onready var timer: Timer = $Timer

var _playing = false
var _played_left = false
var _falling = false


func _ready() -> void:
	EventBus.player_entering.connect(_increase_reverb)
	EventBus.player_leaving.connect(_decrease_reverb)
	var bus = AudioServer.get_bus_index("Reverb")
	var effect = AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
	effect.room_size = smallest_room


func _increase_reverb() -> void:
	var bus = AudioServer.get_bus_index("Reverb")
	var effect = AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
	
	var tween = create_tween()
	tween.tween_property(effect, "room_size", biggest_room, 1.0)


func _decrease_reverb() -> void:
	var bus = AudioServer.get_bus_index("Reverb")
	var effect = AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
	
	var tween = create_tween()
	tween.tween_property(effect, "room_size", smallest_room, 1.0)


func _physics_process(_delta: float) -> void:
	if not player.is_on_floor():
		_playing = false
		_falling = true
		return
	elif _falling:
		_falling = false
		_playing = true
		_played_left = false
		_on_timer_timeout()
	
	if player.velocity.is_zero_approx():
		_playing = false
	elif not _playing:
		_playing = true
		_played_left = false
		_on_timer_timeout()


func _get_delay() -> float:
	var speed_map = clamp((player._speed - player.exhausted_speed) / (player.sprint_speed - player.exhausted_speed), 0, 1)
	_update_volume(speed_map)
	return speed_map * (fastest_delay - slowest_delay) + slowest_delay


func _update_volume(map: float) -> void:
	var bus = AudioServer.get_bus_index("Reverb")
	var vol = map * (loudest_volume - quietest_volume) + quietest_volume
	AudioServer.set_bus_volume_db(bus, linear_to_db(vol))


func _on_timer_timeout() -> void:
	if not _playing:
		return
	
	timer.wait_time = _get_delay()
	
	if _played_left:
		right.play()
	else:
		left.play()
	
	_played_left = not _played_left
	
	timer.start()
