class_name BridgeSwitch
extends Node3D

@export var bridge_paths: Array[NodePath]

@onready var bridges: Array[BridgeRotater] = bridge_paths.map(func(path: NodePath): return get_node(path) as BridgeRotater)

@onready var interactable: SwitchInteractable = $Interactable
@onready var lever: MeshInstance3D = $SwitchLever

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var _is_on := false


func _on_interactable_flipped() -> void:
	var tween = create_tween()
	var target_degrees = 0 if _is_on else 60
	
	_is_on = not _is_on
	
	tween.tween_property(lever, "rotation:x", deg_to_rad(target_degrees), 0.25)
	tween.tween_callback(interactable.enable)
	
	bridges.map(func(bridge: BridgeRotater): bridge.toggle())
	
	audio.play()
	EventBus.noise_made.emit(global_position)
