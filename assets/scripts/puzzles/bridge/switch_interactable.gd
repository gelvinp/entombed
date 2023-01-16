class_name SwitchInteractable
extends Interactable

signal flipped


func get_mouseover_text() -> String:
	return "Flip the switch"


func interact() -> void:
	set("collision_layer", 0)
	flipped.emit()


func enable() -> void:
	set("collision_layer", 4)
