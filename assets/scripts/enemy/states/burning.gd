extends EnemyState


func enter(_msg: Dictionary = {}) -> void:
	if not player.is_on_screen():
		enemy.global_position = player.global_position + (player.transform.basis.z * 3)
		enemy.look_at(player.global_position)
	
	enemy.animation.play("Burn")
	player.state_machine.transition_to("Burning")
