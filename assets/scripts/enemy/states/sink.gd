extends EnemyState

@export var haunt_duration_timer: Timer

func enter(msg: Dictionary = {}) -> void:
	haunt_duration_timer.stop()
	enemy.slide_down()
	await enemy.animation.animation_finished
	EventBus.in_danger.emit(false)
	
	if msg.has("die"):
		owner.queue_free()
	else:
		state_machine.transition_to("Dormant")
