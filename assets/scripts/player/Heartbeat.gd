extends AudioStreamPlayer3D

var vol_target = 0.0
var vol_linear = 0.0
@onready var enemy: Node3D = get_tree().get_first_node_in_group("enemy")
@onready var player: Node3D = get_tree().get_first_node_in_group("player")

var burning := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_db = linear_to_db(0.0)
	EventBus.mound_burn_start.connect(func(): burning = true)


func _process(_delta: float) -> void:
	if EventBus.is_in_danger and not burning:
		vol_target = clampf(enemy.get_danger_factor(), 0.2, 1.0)
	else:
		vol_target = 0.0
	
	vol_linear = lerp(vol_linear, vol_target, 0.05)
	volume_db = linear_to_db(vol_linear)
	
	if vol_linear > 0:
		var player_position = player.global_position
		var enemy_position = enemy.global_position
		var offset = enemy_position - player_position
		position = player_position + offset.normalized()
