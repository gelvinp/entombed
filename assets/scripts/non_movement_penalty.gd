extends Node3D

@export var non_movement_time := 30
@export var whisper_volume_db := -6

@onready var timer: Timer = $Timer
@onready var enemy: Enemy = get_tree().get_first_node_in_group("enemy")
@onready var whisper_volume_linear := db_to_linear(whisper_volume_db)
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var danger_audio: AudioStreamPlayer = $DangerStream

var volume_target := 0.0
var danger_target := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = non_movement_time
	timer.start()
	audio.volume_db = -80
	audio.play()
	danger_audio.volume_db = -80
	danger_audio.play()
	EventBus.mound_burn_start.connect(queue_free, CONNECT_ONE_SHOT)


func _process(_delta: float) -> void:
	var non_movement_factor = (10.0 - minf(10.0, timer.time_left)) / 10.0
	if EventBus.keys_collected < 2:
		non_movement_factor = 0.0
	
	var enemy_factor = enemy.get_distance_factor()
	
	var factor = maxf(non_movement_factor, enemy_factor)
	factor = clampf(factor, 0.0, 1.0)
	
	var volume_linear = factor * whisper_volume_linear
	
	volume_target = lerp(volume_target, volume_linear, 0.05)
	audio.volume_db = linear_to_db(volume_target)
	
	# Danger pass
	var danger_factor = enemy.get_danger_factor()

	danger_target = lerp(danger_target, danger_factor, 0.05)
	danger_audio.volume_db = linear_to_db(danger_target)


func _on_area_3d_body_exited(body: Node3D) -> void:
	global_position = body.global_position
	if timer.is_inside_tree():
		timer.start()


func _on_timer_timeout() -> void:
	EventBus.noise_made.emit(global_position)
	EventBus.haunt_early.emit({ "at_player": true, "slowed": true })
