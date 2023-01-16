extends PlayerState

var look_initial: Vector3
var look_target: Vector3
var look_weight := 0.0:
	get:
		return look_weight
	set(value):
		look_weight = value
		
		var new_target = look_initial.slerp(look_target, value)
		player.look_at(player.global_position + new_target)

func enter(_msg := {}) -> void:
	look_initial = -player.transform.basis.z
	look_target = (get_tree().get_first_node_in_group("enemy").global_position - player.global_position).normalized()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "look_weight", 1.0, 0.75)
	tween.parallel().tween_property(player.neck, "rotation:x", 0.261799, 0.75)
	tween.tween_callback(state_machine.transition_to.bind("PlayerControlled"))
