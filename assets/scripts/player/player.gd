class_name Player
extends CharacterBody3D


@export var walk_speed := 5.0
@export var sprint_speed := 8.0
@export var exhausted_speed := 2.5
@export var look_at_gate_cutscene: Array[Cutscene]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var sprint: Sprint = $Sprint
@onready var state_machine: StateMachine = $StateMachine
@onready var interactable_raycast: RayCast3D = $Neck/InteractRaycast
@onready var shadow_box: CSGBox3D = $Neck/ShadowBox
@onready var key_collected: AudioStreamPlayer = $KeyCollected
@onready var camera: Camera3D = $Neck/Camera3D
@onready var enemy: Node3D = get_tree().get_first_node_in_group("enemy")

@warning_ignore(unused_private_class_variable)
@onready var _speed = walk_speed # Used by the PlayerControlled state
var _speed_tween: Tween

var interactable: Interactable = null:
	get:
		return interactable
	set(value):
		if interactable != value:
			interactable = value
			EventBus.interactable_changed.emit(interactable)



func _ready() -> void:
	sprint.character_target = self
	sprint.sig_sprinting.connect(self._on_sprint)
	sprint.sig_exhausted.connect(self._on_exhaustion)
	sprint.sig_walking.connect(self._on_walk)
	EventBus.player_entering.connect(_on_entered_tomb, CONNECT_ONE_SHOT)
	EventBus.book_read.connect(func(): state_machine.transition_to("Reading"))
	EventBus.book_closed.connect(func(): state_machine.transition_to("PlayerControlled"))
	EventBus.keys_collected_changed.connect(func(_e): key_collected.play())


func _physics_process(_delta: float) -> void:
	interactable = interactable_raycast.get_collider() as Interactable


func _on_entered_tomb() -> void:
	state_machine.transition_to("Cutscene", {"cutscenes": look_at_gate_cutscene, "return_to": "PlayerControlled"})


func _on_sprint():
	if _speed_tween:
		_speed_tween.kill()
	
	_speed_tween = create_tween()
	_speed_tween.tween_property(self, "_speed", sprint_speed, 0.15)


func _on_exhaustion():
	if _speed_tween:
		_speed_tween.kill()
	
	_speed_tween = create_tween()
	_speed_tween.tween_property(self, "_speed", exhausted_speed, 0.2)


func _on_walk():
	if _speed_tween:
		_speed_tween.kill()
	
	_speed_tween = create_tween()
	_speed_tween.tween_property(self, "_speed", walk_speed, 0.3)


func can_see_enemy() -> bool:
	var enemy_face = enemy.global_position + Vector3(0, 2, 0)
	if not camera.is_position_behind(enemy_face):
		var screen_position = camera.unproject_position(enemy_face)
		
		if not get_viewport().get_visible_rect().has_point(screen_position):
			return false
		
		var dist_from_center = (
			Vector2(DisplayServer.screen_get_size() / 2) - screen_position
		).length_squared()
		
		return dist_from_center < 40000
	return false


func is_on_screen() -> bool:
	var enemy_face = enemy.global_position + Vector3(0, 2, 0)
	if not camera.is_position_behind(enemy_face):
		var screen_position = camera.unproject_position(enemy_face)
		if get_viewport().get_visible_rect().has_point(screen_position):
			var space_state = get_world_3d().direct_space_state
			var params = PhysicsRayQueryParameters3D.create(
				global_position + Vector3(0, 1.5, 0),
				enemy.global_position + Vector3(0, 2, 0),
				0xFFFFFFFF,
				[self.get_rid()]
			)
			var result = space_state.intersect_ray(params)
			return result["collider"] is Enemy
	
	return false
