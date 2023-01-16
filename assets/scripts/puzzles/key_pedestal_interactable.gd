class_name KeyPedestalInteractable
extends Interactable

@onready var key = $key
@onready var pedestal: StaticBody3D = $story

signal picked_up

func get_mouseover_text() -> String:
	return "Pickup the key"


func interact() -> void:
	EventBus.keys_collected += 1
	set("collision_layer", 0)
	EventBus.noise_made.emit(global_position)
	key.queue_free()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(pedestal, "position:y", -2, 1)
	tween.tween_callback(func(): queue_free())
	picked_up.emit()


func _on_encounter_area_body_entered(_body: Node3D) -> void:
	EventBus.encountered_interaction = true
