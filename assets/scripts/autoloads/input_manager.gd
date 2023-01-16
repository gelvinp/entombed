extends Node

signal DeviceChanged

enum DEVICE
{
	KEYBOARD_MOUSE,
	SONY,
	NINTENDO,
	MICROSOFT
}

var ActiveDevice: DEVICE = DEVICE.KEYBOARD_MOUSE:
	get:
		return ActiveDevice
	set(value):
		var should_emit = value != ActiveDevice
		ActiveDevice = value
		if should_emit:
			DeviceChanged.emit()

var _sony_regex := RegEx.new()
var _nintendo_regex := RegEx.new()

var Interact:
	get:
		match ActiveDevice:
			DEVICE.KEYBOARD_MOUSE:
				return "Left Mouse"
			DEVICE.SONY:
				return "X"
			DEVICE.NINTENDO:
				return "B"
			DEVICE.MICROSOFT:
				return "A"
			_:
				return ""

var Escape:
	get:
		match ActiveDevice:
			DEVICE.KEYBOARD_MOUSE:
				return "Escape"
			DEVICE.SONY:
				return "Circle"
			DEVICE.NINTENDO:
				return "A"
			DEVICE.MICROSOFT:
				return "B"
			_:
				return ""

var Sprint:
	get:
		match ActiveDevice:
			DEVICE.KEYBOARD_MOUSE:
				return "Shift"
			DEVICE.SONY:
				return "Square"
			DEVICE.NINTENDO:
				return "Y"
			DEVICE.MICROSOFT:
				return "X"
			_:
				return ""


func _ready() -> void:
	_sony_regex.compile(".*(ps|dual|sony).*")
	_nintendo_regex.compile(".*(nintendo|pro controller)")


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse:
		ActiveDevice = DEVICE.KEYBOARD_MOUSE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		var joy_name = Input.get_joy_name(0).to_lower()
		
		if _sony_regex.search(joy_name):
			ActiveDevice = DEVICE.SONY
		elif _nintendo_regex.search(joy_name):
			ActiveDevice = DEVICE.NINTENDO
		else:
			ActiveDevice = DEVICE.MICROSOFT
