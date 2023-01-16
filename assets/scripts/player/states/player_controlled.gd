extends PlayerState


func physics_process(delta: float) -> void:
	# Add the gravity.
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta
	
	var joy_look_horiz = Input.get_axis("look_left", "look_right")
	var joy_look_vert = Input.get_axis("look_up", "look_down")
	
	player.rotate_y(-joy_look_horiz * SettingsManager.look_sensitivity_adj * 20)
	player.neck.rotate_x(-joy_look_vert * SettingsManager.look_sensitivity_adj * 20)
	player.neck.rotation.x = clamp(player.neck.rotation.x, -PI/2, PI/2)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward")
	var direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * player._speed
		player.velocity.z = direction.z * player._speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player._speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player._speed)

	player.move_and_slide()


func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * SettingsManager.look_sensitivity_adj)
		player.neck.rotate_x(-event.relative.y * SettingsManager.look_sensitivity_adj)
		player.neck.rotation.x = clamp(player.neck.rotation.x, -PI/2, PI/2)
	elif (
		event.is_action_pressed("interact") and
		player.interactable != null
	):
		player.interactable.interact()
