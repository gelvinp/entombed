class_name MoundInteractable
extends Interactable

signal start_burn


func get_mouseover_text() -> String:
	return "Burn the mound"


func interact() -> void:
	start_burn.emit()
	set("collision_layer", 0)
