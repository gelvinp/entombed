extends Node3D

@onready var animation: AnimationPlayer = $AnimationPlayer
var burn_it := true


func _ready() -> void:
	EventBus.player_entered_region.connect(_player_region)


func _player_region(region: EventBus.REGION) -> void:
	if burn_it and region == EventBus.REGION.BURIAL_CHAMBER:
		burn_it = false
		_burn_it()


func _on_animatable_body_3d_door_unlocked() -> void:
	animation.play("open")
	EventBus.noise_made.emit(global_position)


func _burn_it() -> void:
	EventBus.enqueue_guidance.emit("[color=red]Burn It[/color]")
	EventBus.burial_chamber_accessable.emit()
