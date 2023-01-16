extends PlayerState

@export var duration := 1.0

func enter(_msg := {}) -> void:
	player.velocity = Vector3.ZERO
	player.shadow_box.visible = true
	
	var tween = create_tween()
	tween.tween_property(player.shadow_box, "transparency", 0, 0.5)
	tween.tween_callback(func(): player.rotation.y = PI/2)
	tween.tween_property(player.shadow_box, "transparency", 1, 0.5).set_delay(0.25)
	tween.tween_callback(self.finished)


func finished() -> void:
	player.shadow_box.visible = false
	player.state_machine.transition_to("PlayerControlled")
