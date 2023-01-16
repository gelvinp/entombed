extends EnemyState

var movement_speed: float


func enter(msg: Dictionary = {}) -> void:
	if msg.has("non_key"):
		if EventBus.keys_collected > 2:
			enemy.position = player.global_position
	elif msg.has("at_player"):
		enemy.position = player.global_position
	elif EventBus.keys_collected == 2:
		match EventBus.player_region:
			EventBus.REGION.BRIDGE_PUZZLE, EventBus.REGION.MAZE_PUZZLE:
				enemy.position = player.global_position
			EventBus.REGION.PREVENTION_PUZZLE:
				enemy.position = LocationDatabase.gpos_of("WP_PreventionPuzzle")
			EventBus.REGION.STORY_PUZZLE:
				enemy.position = LocationDatabase.gpos_of("WP_StoryPuzzle")
	elif EventBus.keys_collected > 2:
		enemy.position = player.global_position
	
	enemy.slide_up()
	EventBus.in_danger.emit(true)
	enemy.animation.animation_finished.connect(begin_search, CONNECT_ONE_SHOT)
	
	if msg.has("slowed"):
		movement_speed = enemy.slower_movement_speed
	else:
		movement_speed = enemy.movement_speed


func begin_search(_a) -> void:
	state_machine.transition_to("Search", { "suspected": player.global_position, "speed": movement_speed })
