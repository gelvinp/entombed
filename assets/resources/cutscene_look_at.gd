class_name LookAtCutscene
extends Cutscene

@export var target_name: String
@export var tween_duration: float
@export var look_duration: float

var player: Player
var _player_from: float
var _player_to: float
var _neck_from: float
var _neck_to: float

var _weight := 0.0:
	get:
		return _weight
	set(value):
		var player_angle = lerp_angle(_player_from, _player_to, value)
		var neck_angle = lerp_angle(_neck_from, _neck_to, value)
		player.rotation.y = player_angle
		player.neck.rotation.x = neck_angle
		_weight = value


func run(scene_tree: SceneTree, finished: Callable) -> void:
	var target = (scene_tree
		.get_nodes_in_group("cutscene_look_at")
		.filter(func(e: Node): return e.name == target_name)
		.front()
	) as Node3D
	assert(target != null)
	
	player = scene_tree.get_first_node_in_group("player") as Player
	assert(player != null)
	
	var player_target = Vector3(target.global_position.x, player.global_position.y, target.global_position.z)
	var _neck_target = Vector3(player.neck.global_position.x, target.global_position.y, player.neck.global_position.z) - player.neck.transform.basis.z
	
	var player_dist = player.global_position.direction_to(player_target)
	var neck_dist = player.neck.global_position.direction_to(target.global_position)
	
	var neck_forward = neck_dist
	neck_forward.y = 0
	neck_forward = neck_forward.normalized()
	
	_player_from = player.rotation.y
	_player_to = -atan2(player_dist.x, abs(player_dist.z))
	
	_neck_from = player.neck.rotation.x
	_neck_to = neck_forward.angle_to(neck_dist)
	
	var tween = scene_tree.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "_weight", 1.0, tween_duration)
	await tween.finished
	
	await scene_tree.create_timer(look_duration).timeout
	
	finished.call()
