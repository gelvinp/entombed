extends Node

@export var initial_scene: PackedScene

@onready var cover: Control = $Cover
#@onready var progress: TextureProgressBar = $Cover/VBoxContainer/TextureProgressBar

var _tween: Tween
var _scene: Node

var _waiting_on := ""
var _message = {}


func _ready() -> void:
	randomize()
	EventBus.scene_change.connect(self._scene_change)
	EventBus.scene_change_with_message.connect(self._scene_change_with_message)
	
	_scene = initial_scene.instantiate()
	add_child(_scene)
	_scene.owner = self
	move_child(_scene, 0)
	cover.modulate = Color(1, 1, 1, 0)
	cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("_update_sizes")


func _update_sizes() -> void:
	DisplayServer.window_set_size(DisplayServer.screen_get_size())
	get_tree().get_root().set_content_scale_size(DisplayServer.screen_get_size())


func _process(_delta: float) -> void:
	if _waiting_on != "":
		var progress_array = [0]
		var status = ResourceLoader.load_threaded_get_status(_waiting_on, progress_array)
		
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Thread Load Failed at " + _waiting_on)
			get_tree().quit()
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			_finish_load_scene()
		elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
			#print(progress_array)


func _insert_scene(scene: PackedScene) -> void:
	_scene = scene.instantiate()
	
	add_child(_scene)
	_scene.owner = self
	move_child(_scene, 0)
	
	if _message.size() > 0:
		_scene.call("receive_message", _message)
	
	_fade_out_cover()


func _fade_out_cover() -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(cover, "modulate", Color(1, 1, 1, 0), 1)
	_tween.tween_callback((func(e): e.mouse_filter = Control.MOUSE_FILTER_IGNORE).bind(cover))


func _fade_in_cover(scene_path: String) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(cover, "modulate", Color(1, 1, 1, 1), 1)
	_tween.tween_callback(self._start_load_scene.bind(scene_path))
	
	cover.mouse_filter = Control.MOUSE_FILTER_STOP


func _start_load_scene(scene_path: String) -> void:
	_scene.queue_free()
	_waiting_on = scene_path


func _finish_load_scene() -> void:
	var scene = ResourceLoader.load_threaded_get(_waiting_on) as PackedScene
	
	if not scene:
		printerr("Failed to load scene at " + _waiting_on)
		get_tree().quit()
	
	_insert_scene(scene)
	_waiting_on = ""
	

func _scene_change(scene_path: String, message: Dictionary = {}) -> void:
	_message = message
	ResourceLoader.load_threaded_request(scene_path, "PackedScene", false, ResourceLoader.CACHE_MODE_REUSE)
	_fade_in_cover(scene_path)
	

func _scene_change_with_message(scene_path: String, message: Dictionary) -> void:
	_scene_change(scene_path, message)
