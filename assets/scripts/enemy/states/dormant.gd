extends EnemyState

@onready var dormant_timer: Timer = $DormantTimer


func enter(_msg: Dictionary = {}) -> void:
	EventBus.keys_collected_changed.connect(_on_key_collected, CONNECT_ONE_SHOT)
	
	if EventBus.keys_collected >= 2:
		dormant_timer.start()
		EventBus.haunt_early.connect(func(flags: Dictionary): state_machine.transition_to("Haunt", flags), CONNECT_ONE_SHOT)


func exit(_leaving_for: String) -> void:
	dormant_timer.stop()


func _on_key_collected(count: int) -> void:
	match count:
		1:
			state_machine.transition_to("Ambush")
		2:
			EventBus.enqueue_guidance.emit("Press %s to sprint.\nDon't become exhausted. Don't be seen." % InputManager.Sprint)
			state_machine.transition_to("Haunt")
		3, 4:
			state_machine.transition_to("Haunt")
		_:
			printerr("Enemy doesn't know how to handle %d keys" % count)


func _on_dormant_timer_timeout() -> void:
	state_machine.transition_to("Haunt", { "non_key": true })
