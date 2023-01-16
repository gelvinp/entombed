extends Node3D

@onready var enter_area: Area3D = $Area3D


func _on_area_3d_body_entered(_body: Node3D) -> void:
	if not OS.has_feature("debug"):
		EventBus.player_entering.emit()
