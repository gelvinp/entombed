class_name EnemyState
extends State

var enemy: Enemy
var player: Player


func _ready() -> void:
	await owner.ready
	
	enemy = owner as Enemy
	assert(enemy != null)
	
	player = get_tree().get_first_node_in_group("player")
	assert(player != null)
