extends HSlider


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("ui_left"):
		get_viewport().set_input_as_handled()
	elif event.is_action("ui_right"):
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if has_focus():
		if Input.is_action_pressed("ui_left"):
			value -= step
		elif Input.is_action_pressed("ui_right"):
			value += step
		elif Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
			drag_ended.emit(true)
