extends Control

@onready var image_1: TextureRect = get_node("%Image1")
@onready var image_2: TextureRect = get_node("%Image2")
@onready var image_3: TextureRect = get_node("%Image3")

@onready var left_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/LeftButton
@onready var right_button: TextureButton = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RightButton

@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label

var current_page = 0
var max_page = 2

@onready var pages = [
	get_node("%Page1"),
	get_node("%Page2"),
	get_node("%Page3")
]


func _ready() -> void:
	PuzzleManager.StoryReady.connect(_prepare)
	EventBus.book_read.connect(_show)
	InputManager.DeviceChanged.connect(_set_label)
	_set_label()
	
	call_deferred("_update_size")


func _update_size() -> void:
	await get_tree().process_frame
	
	var overdraw_ratio = DisplayServer.screen_get_size().y / $PanelContainer.size.y
	
	if overdraw_ratio < 1:
		$PanelContainer.scale *= overdraw_ratio
		
		var shift_amount = (DisplayServer.screen_get_size().x / 2.0) * (1 - overdraw_ratio)
		$PanelContainer.position = Vector2(shift_amount, 0)


func _set_label() -> void:
	label.text = "Press %s to close" % InputManager.Escape


func _prepare(solution: Array[StoryPair]) -> void:
	image_1.texture = solution[0].correct_choice
	image_2.texture = solution[1].correct_choice
	image_3.texture = solution[2].correct_choice


func _show() -> void:
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


# Called when the node enters the scene tree for the first time.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and visible:
		get_viewport().set_input_as_handled()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		visible = false
		EventBus.book_closed.emit()
	elif event.is_action_pressed("ui_left") and visible and not left_button.disabled:
		_on_button_pressed(-1)
	elif event.is_action_pressed("ui_right") and visible and not right_button.disabled:
		_on_button_pressed(1)


func _on_button_pressed(direction: int) -> void:
	pages[current_page].visible = false
	current_page += direction
	pages[current_page].visible = true
	
	check_buttons()


func check_buttons() -> void:
	left_button.disabled = current_page == 0
	right_button.disabled = current_page >= max_page
