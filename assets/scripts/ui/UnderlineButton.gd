extends RichTextLabel

signal clicked

var _text := ""

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	_text = text
	bbcode_enabled = true
	
	custom_minimum_size = get_theme_font("normal_font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, get_theme_font_size("normal_font_size")) + Vector2(10, 0)


func _on_mouse_entered() -> void:
	grab_focus()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event = event as InputEventMouseButton
		
		if (button_event.button_index == 1) and button_event.pressed:
			clicked.emit()
			audio.play()
			text = _text
	elif event.is_action_pressed("ui_accept"):
		clicked.emit()


func _on_focus_entered() -> void:
	text = "[u]" + _text


func _on_focus_exited() -> void:
	text = _text
