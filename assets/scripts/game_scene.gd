extends MarginContainer

@export var blue_colors: Array[Color]
@export var red_colors: Array[Color]

@onready var svc: SubViewportContainer = $SubViewportContainer
@onready var player: CharacterBody3D = $SubViewportContainer/SubViewport/World/Player

@onready var pause_container: PanelContainer = $SubViewportContainer/SubViewport/PanelContainer
@onready var pause_menu: Control = $SubViewportContainer/SubViewport/PanelContainer/CenterContainer/OptionsInGame
@onready var pause_sound: AudioStreamPlayer = $PauseSound

var debug_mode = 0

var red_weight: float = 0.0:
	get:
		return red_weight
	set(value):
		red_weight = value
		
		var colors = lerp_colors(blue_colors, red_colors, red_weight)
		var mapped = map_colors(colors)
		(svc.material as ShaderMaterial).set_shader_parameter("colors", mapped)

var radius: float = 0.0:
	get:
		return radius
	set(value):
		radius = value
		
		(svc.material as ShaderMaterial).set_shader_parameter("radius", radius)

var bias: float = 0.0:
	get:
		return bias
	set(value):
		bias = value
		(svc.material as ShaderMaterial).set_shader_parameter("bias", bias)


func _ready() -> void:
	var colors = map_colors(blue_colors)
	(svc.material as ShaderMaterial).set_shader_parameter("colors", colors)
	
	Engine.max_fps = 60
	EventBus.player_entering.connect(slam_gate, CONNECT_ONE_SHOT)
	EventBus.mound_burn_end.connect(open_gate)
	EventBus.in_danger.connect(_in_danger)
	EventBus.player_death.connect(_player_death)
	PuzzleManager.prepare()
	call_deferred("_update_sizes")


func _update_sizes() -> void:
	await get_tree().process_frame
	size = DisplayServer.screen_get_size()
	position = Vector2i.ZERO


func slam_gate() -> void:
	EventBus.gate_status.emit(false)
	await EventBus.gate_shut
	
	var bus = AudioServer.get_bus_index("Reverb")
	var effect = AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "radius", 1.0, 1.0)
	tween.parallel().tween_property(effect, "dry", 0.5, 1.0)
	debug_mode = 1


func open_gate() -> void:
	EventBus.gate_status.emit(true)
	
	var bus = AudioServer.get_bus_index("Reverb")
	var effect = AudioServer.get_bus_effect(bus, 0) as AudioEffectReverb
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "radius", 0.0, 3.0)
	tween.parallel().tween_property(effect, "dry", 1.0, 3.0)
	debug_mode = 0


func _in_danger(danger: bool) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "red_weight", 1.0 if danger else 0.0, 1.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if OS.has_feature("debug"):
			debug_advance()
	elif event.is_action_pressed("ui_end") and OS.has_feature("debug"):
		EventBus.keys_collected = 4
	elif event.is_action_pressed("pause"):
		pause_container.visible = true
		pause_sound.play()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.prepare()
		get_tree().paused = true


func debug_advance():
	if debug_mode == 0:
		EventBus.gate_status.emit(false)
		await EventBus.gate_shut
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(self, "radius", 1.0, 1.0)
		debug_mode = 1
	elif debug_mode == 1:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "red_weight", 1.0, 1.0)
		debug_mode = 2
	elif debug_mode == 2:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "radius", 0.0, 1.0)
		tween.tween_property(self, "red_weight", 0, 0.1)
		debug_mode = 0
		EventBus.gate_status.emit(true)


func lerp_colors(a: Array[Color], b: Array[Color], weight: float) -> Array[Color]:
	var output: Array[Color] = []
	
	if a.size() != b.size():
		return output
	
	for idx in range(a.size()):
		output.append(a[idx].lerp(b[idx], weight))
	
	return output


func map_colors(colors: Array[Color]) -> Array[Vector3]:
	return colors.map(func(c): return Vector3(c.r, c.g, c.b))


func _on_options_in_game_close() -> void:
		pause_container.visible = false
		pause_sound.play()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().paused = false


func _exit_tree() -> void:
	LocationDatabase.locations.clear()
	EventBus.reset()


func _player_death() -> void:
	var tween = create_tween()
	tween.tween_property(self, "bias", -1.0, 3.0)
	tween.tween_callback(EventBus.emit_signal.bind(
		"scene_change_with_message",
		"res://assets/scenes/main_menu/main_menu.tscn",
		{ "victory": false })).set_delay(1.0)
