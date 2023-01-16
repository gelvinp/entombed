extends StaticBody3D

@onready var animation: AnimationPlayer = $AnimationPlayer


func _on_area_3d_start_burn() -> void:
	EventBus.mound_burn_start.emit()
	animation.play("burn")


func _burn_finished() -> void:
	EventBus.mound_burn_end.emit()
	queue_free()
