extends Node

enum RESOLUTION
{
	HD_720,
	WXGA_768,
	HDP_900,
	FHD_1080
}

var resolution: RESOLUTION:
	get:
		return _resolution
	set(value):
		var resolution_index = value
		_init_resolution(RESOLUTION_WIDTHS[resolution_index][1])

var full_screen: bool:
	get:
		return _fullscreen
	set(value):
		_init_fullscreen(value)

var volume: float:
	get:
		return _volume
	set(value):
		_init_volume(clamp(value, 0, 1))

var look_sensitivity: float:
	get:
		return _look_sensitivity
	set(value):
		_init_look_sensitivity(clamp(value, 0.01, 1))


var look_sensitivity_adj: float:
	get:
		return _look_sensitivity / 100.0

var _resolution: RESOLUTION
var _fullscreen: bool
var _volume: float
var _look_sensitivity: float

const RESOLUTION_WIDTHS = [
		[RESOLUTION.HD_720, 1280],
		[RESOLUTION.WXGA_768, 1366],
		[RESOLUTION.HDP_900, 1600],
		[RESOLUTION.FHD_1080, 1920]
	]

func persist() -> void:
	var prefs = FileAccess.open("user://prefs", FileAccess.WRITE)
	#prefs.store_8(_resolution)
	#prefs.store_8(1 if _fullscreen else 0)
	prefs.store_float(_volume)
	prefs.store_float(_look_sensitivity)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var desired_width = DisplayServer.screen_get_size().x
	#var desired_fullscreen = true
	var desired_volume = 0.65
	var desired_look_sensitivity = 0.5
	
	var prefs = FileAccess.open("user://prefs", FileAccess.READ)
	
	if prefs and prefs.get_length() == 8:
		#var resolution_index = prefs.get_8()
		#desired_width = RESOLUTION_WIDTHS[resolution_index][1]
		#desired_fullscreen = prefs.get_8() > 0
		desired_volume = prefs.get_float()
		desired_look_sensitivity = prefs.get_float()
	
	#_init_fullscreen(desired_fullscreen)
	#_init_resolution(desired_width)
	_init_volume(desired_volume)
	_init_look_sensitivity(desired_look_sensitivity)
	
	persist()


func _init_resolution(desired_width: int) -> void:
	if _fullscreen:
		_resolution = RESOLUTION.FHD_1080
		return
	
	var error = RESOLUTION_WIDTHS.map(func(e): return [e[0], abs(desired_width - e[1])])
	error.sort_custom(func(a, b): return a[1] < b[1])
	var closest_match = error[0]
	
	_resolution = closest_match[0]
	var width = RESOLUTION_WIDTHS[_resolution][1]
	var height = width * 9.0 / 16.0
	
	DisplayServer.window_set_size(Vector2i(width, height), 0)


func _init_fullscreen(desired_fullscreen: bool) -> void:
	_fullscreen = desired_fullscreen
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN if desired_fullscreen else DisplayServer.WINDOW_MODE_WINDOWED, 0)
	if not desired_fullscreen:
		get_tree().get_root().borderless = false


func _init_volume(desired_volume: float) -> void:
	_volume = desired_volume
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(desired_volume))


func _init_look_sensitivity(desired_sensitivity: float) -> void:
	_look_sensitivity = desired_sensitivity
