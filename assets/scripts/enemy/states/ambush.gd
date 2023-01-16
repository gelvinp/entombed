extends EnemyState

var looking := true
var look_direction: Vector3


func enter(_msg: Dictionary = {}) -> void:
	enemy.position = LocationDatabase.gpos_of("WP_Ambush")
	enemy.reset_particles.call_deferred()
	enemy.body.visible = true
	
	match EventBus.player_region:
		EventBus.REGION.BRIDGE_PUZZLE:
			look_direction = (LocationDatabase.gpos_of("LP_BridgePuzzle") - enemy.global_position).normalized()
		EventBus.REGION.PREVENTION_PUZZLE:
			look_direction = (LocationDatabase.gpos_of("LP_PreventionPuzzle") - enemy.global_position).normalized()
		EventBus.REGION.STORY_PUZZLE:
			look_direction = (LocationDatabase.gpos_of("LP_StoryPuzzle") - enemy.global_position).normalized()
		EventBus.REGION.MAZE_PUZZLE:
			look_direction = (LocationDatabase.gpos_of("LP_MazePuzzle") - enemy.global_position).normalized()


func process(_delta: float) -> void:
	if looking:
		if enemy.can_see_player() and (
			player.can_see_enemy() or
			abs(player.global_position.x) < 12
		):
			looking = false
			EventBus.in_danger.emit(true)
			get_tree().create_timer(2).timeout.connect(_hide, CONNECT_ONE_SHOT)
	else:
		var player_offset = (enemy.player.global_position - enemy.global_position).normalized()
		look_direction = look_direction.slerp(player_offset, 0.05)
	
	enemy.look_at(enemy.global_position + look_direction)
	enemy.player.can_see_enemy()


func _hide() -> void:
	state_machine.transition_to("Sink")
