extends StaticBody3D


func braid() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:y", -5, 1)
	tween.tween_callback(func(): queue_free())
