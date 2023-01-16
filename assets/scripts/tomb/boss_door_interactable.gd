class_name BossDoorInteractable
extends Interactable

signal door_unlocked

var keys_needed := 4

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	EventBus.keys_collected_changed.connect(_on_key_collected)


func _on_key_collected(keys: int) -> void:
	keys_needed = 4 - keys


func get_mouseover_text() -> String:
	if keys_needed > 0:
		return str(keys_needed) + (" key%s needed" % ("s" if keys_needed > 1 else ""))
	
	return "Open the burial chamber"


func interact() -> void:
	if keys_needed == 0:
		set("collision_layer", 1)
		door_unlocked.emit()
	elif not audio.playing:
		audio.play()
