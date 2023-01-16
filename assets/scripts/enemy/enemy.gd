class_name Enemy
extends CharacterBody3D

@export_range(0, PI, 0.01) var sight_angle
@export var sight_range: float
@export var movement_speed: float
@export var slower_movement_speed: float

@onready var player: Player = get_tree().get_first_node_in_group("player")
@onready var sight_range_squared = sight_range * sight_range
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles3D = $Body/GPUParticles3D
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_machine: StateMachine = $StateMachine
@onready var body: Node3D = $Body


func _ready() -> void:
	EventBus.mound_burn_start.connect(state_machine.transition_to.bind("Burning"), CONNECT_ONE_SHOT)
	body.visible = false


func can_see_player() -> bool:
	var player_offset = (global_position - player.global_position)
	var player_offset_length = player_offset.length_squared()
	
	if player_offset_length > sight_range_squared:
		return false
	
	var player_angle = transform.basis.z.angle_to(player_offset)
	if (player_angle > sight_angle):
		return false
	
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(
		global_position + Vector3(0, 2, 0),
		player.global_position + Vector3(0, 1.5, 0),
		0xFFFFFFBF, # Exclude columns
		[self.get_rid()]
	)
	var result = space_state.intersect_ray(params)
	return result["collider"] is Player


func slide_down() -> void:
	animation.play("SlideDown")


func slide_up() -> void:
	animation.play("SlideUp")


func reset_particles() -> void:
	particles.speed_scale = 8
	await get_tree().create_timer(1).timeout
	particles.speed_scale = 1


func get_distance_factor() -> float:
	if not body.visible or state_machine.get_state().name != "Ambush":
		return 0.0
	
	var player_offset = global_position - player.global_position
	var player_distance = maxf(0.0, player_offset.length() - 14.0)
	
	return clampf((10.0 - player_distance) / 10.0, 0.0, 1.0)


func get_danger_factor() -> float:
	if not body.visible or not EventBus.is_in_danger:
		return 0.0
	
	var player_offset = global_position - player.global_position
	var player_distance = maxf(0.0, player_offset.length() - 8.0)
	
	return clampf((17.0 - player_distance) / 17.0, 0.0, 1.0)
