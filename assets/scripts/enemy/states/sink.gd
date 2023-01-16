extends EnemyState

@export_node_path(Timer) var haunt_duration_timer_node_path: NodePath
@onready var haunt_duration_timer: Timer = get_node(haunt_duration_timer_node_path)

func enter(msg: Dictionary = {}) -> void:
	haunt_duration_timer.stop()
	enemy.slide_down()
	await enemy.animation.animation_finished
	EventBus.in_danger.emit(false)
	
	if msg.has("die"):
		owner.queue_free()
	else:
		state_machine.transition_to("Dormant")
