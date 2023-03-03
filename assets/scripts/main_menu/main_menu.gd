extends Control

@export var blue_colors: Array[Color]
@export var red_colors: Array[Color]

@onready var options = $SubViewportContainer/SubViewport/PanelContainer
@onready var options_form = $SubViewportContainer/SubViewport/PanelContainer/CenterContainer/OptionsFull
@onready var svc: SubViewportContainer = $SubViewportContainer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var gate = $SubViewportContainer/SubViewport/SubViewportContainer/SubViewport/Gate

var tween: Tween

var _audio_linear: float = 0.0:
	get:
		return _audio_linear
	set(value):
		_audio_linear = value
		audio.volume_db = linear_to_db(value)


func _ready() -> void:
	tween = create_tween()
	tween.tween_property(self, "_audio_linear", 1, 3)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var colors = map_colors(blue_colors)
	(svc.material as ShaderMaterial).set_shader_parameter("colors", colors)
	(svc.material as ShaderMaterial).set_shader_parameter("radius", 1)
	call_deferred("_update_sizes")


func _update_sizes() -> void:
	await get_tree().process_frame
	size = DisplayServer.screen_get_size()
	$SubViewportContainer/SubViewport/SubViewportContainer/SubViewport.size = size
	$SubViewportContainer/SubViewport/SubViewportContainer.size = size
	$SubViewportContainer/SubViewport/SubViewportContainer.position = Vector2(size.x, 0)
	$SubViewportContainer/SubViewport/VBoxContainer/Play.grab_focus()


func _on_play_clicked() -> void:
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "_audio_linear", 0, 1)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventBus.scene_change.emit("res://assets/scenes/game_scene.tscn")


func _on_options_clicked() -> void:
	options_form.prepare()
	options.visible = true


func _on_quit_clicked() -> void:
	get_tree().quit()


func _on_options_full_close() -> void:
	options.visible = false
	$SubViewportContainer/SubViewport/VBoxContainer/Options.grab_focus()


func map_colors(colors: Array[Color]) -> Array[Vector3]:
	return Array(colors.map(func(c): return Vector3(c.r, c.g, c.b)), TYPE_VECTOR3, "", null)


func receive_message(message: Dictionary) -> void:
	if message.has("victory"):
		if message["victory"]:
			(svc.material as ShaderMaterial).set_shader_parameter("radius", 0)
			gate.visible = false
		else:
			var colors = map_colors(red_colors)
			(svc.material as ShaderMaterial).set_shader_parameter("colors", colors)
