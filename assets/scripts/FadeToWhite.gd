extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.player_leaving.connect(fade)


func fade() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "color", Color(1, 1, 1, 1), 2.0)
	
	await tween.finished
	
	EventBus.scene_change_with_message.emit(
		"res://assets/scenes/main_menu/main_menu.tscn",
		{ "victory": true }
	)
