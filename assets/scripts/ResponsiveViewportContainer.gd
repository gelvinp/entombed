extends SubViewport


func _ready() -> void:
	call_deferred("_update")


func _update() -> void:
	size = DisplayServer.screen_get_size()
