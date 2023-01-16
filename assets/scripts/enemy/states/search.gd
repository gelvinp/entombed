extends EnemyState

var movement_speed: float

@onready var timer: Timer = $HauntDuration

var look_direction: Vector3
var suspected_position: Vector3:
	get:
		return suspected_position
	set(value):
		suspected_position = value
		enemy.agent.target_location = value


func enter(msg: Dictionary = {}) -> void:
	if msg.has("suspected"):
		suspected_position = msg["suspected"]
	else:
		suspected_position = enemy.global_position
	
	if msg.has("speed"):
		movement_speed = msg["speed"]
	else:
		movement_speed = enemy.movement_speed
	
	look_direction = enemy.transform.basis.z
	enemy.agent.target_reached.connect(target_reached)
	EventBus.noise_made.connect(noise_heard)
	
	if EventBus.keys_collected < 4:
		timer.start()
	
	EventBus.keys_collected_changed.connect(func(_e): if not timer.is_stopped(): timer.start())


func exit(_leaving_for: String) -> void:
	enemy.agent.target_reached.disconnect(target_reached)
	EventBus.noise_made.disconnect(noise_heard)


func target_reached() -> void:
	await get_tree().create_timer(3).timeout
	
	while true:
		var region_rid = get_tree().get_first_node_in_group("navregion").get_region_rid()
		var map_rid = NavigationServer3D.region_get_map(region_rid)
		var random_point = Vector3(randf_range(-27, 27), 0, randf_range(-6, 6))
		var closest_on_map = NavigationServer3D.map_get_closest_point(map_rid, random_point)
		
		if (closest_on_map - enemy.global_position).length_squared() > 100:
			suspected_position = closest_on_map
			return


func process(_delta: float) -> void:
	move_towards_suspected_location()
	look_for_player()


func physics_process(_delta: float) -> void:
	if (
		(enemy.global_position - player.global_position).length_squared() < 1.5625 and
		player.state_machine.get_state().name != "Death"
	):
		player.state_machine.transition_to("Death")


func move_towards_suspected_location() -> void:
	var next_location = enemy.agent.get_next_location()
	var direction = (next_location - enemy.global_position).normalized()
	look_direction = look_direction.slerp(direction, 0.05)
	enemy.look_at(enemy.global_position + look_direction)
	enemy.velocity = direction * movement_speed
	enemy.move_and_slide()


func look_for_player() -> void:
	if enemy.can_see_player():
		suspected_position = player.global_position


func noise_heard(position: Vector3) -> void:
	suspected_position = position


func _on_haunt_duration_timeout() -> void:
	state_machine.transition_to("Sink")
