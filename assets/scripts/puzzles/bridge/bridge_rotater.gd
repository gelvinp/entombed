class_name BridgeRotater
extends AnimatableBody3D

@export var rotation_speed = 3.0
@export var rotation_target: float = PI / 2.0
@export var disable_collision_on_rotate: bool = true
@export_node_path(TorchToggleable) var torch_path

@onready var surface_collision: CollisionShape3D = $SurfaceCollision
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var torch: TorchToggleable = get_node(torch_path) if torch_path else null

@onready var audio: AudioStreamPlayer3D = $Movement

var _rotation_target = 0


func _ready() -> void:
	animation.play("Walkable")


func toggle(with_sound: bool = true) -> void:
	if with_sound:
		audio.play()
	
	if _rotation_target == 0:
		_rotation_target = rotation_target
		surface_collision.disabled = disable_collision_on_rotate
		animation.play("NonWalkable" if disable_collision_on_rotate else "StillWalkable")
		if torch:
			torch.active = false
	else:
		_rotation_target = 0
		animation.play("Walkable")
		if torch:
			torch.active = true
		
		var anim_name = await animation.animation_finished
		if anim_name == "Walkable":
			surface_collision.disabled = false
