class_name KeyInteractable
extends Interactable


func get_mouseover_text() -> String:
	return "Pickup the key"


func interact() -> void:
	EventBus.keys_collected += 1
	EventBus.noise_made.emit(global_position)
	set("collision_layer", 0)
	queue_free()


func enable() -> void:
	set("collision_layer", 4)
