extends Control

signal close

@onready var resolution_label: Label = $PanelContainer/MarginContainer/OptionsForm/Label
@onready var resolution: OptionButton = $PanelContainer/MarginContainer/OptionsForm/Resolution
@onready var full_screen: CheckBox = $PanelContainer/MarginContainer/OptionsForm/Fullscreen
@onready var volume: HSlider = $PanelContainer/MarginContainer/OptionsForm/Volume
@onready var look_sensitivity: HSlider = $"PanelContainer/MarginContainer/OptionsForm/Look Sensitivity"


func _on_rich_text_label_clicked() -> void:
	close.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close.emit()


func prepare() -> void:
	#resolution.select(max(0, SettingsManager.resolution))
	#full_screen.button_pressed = SettingsManager.full_screen
	#_on_fullscreen_toggled(SettingsManager.full_screen)
	volume.value = SettingsManager.volume
	look_sensitivity.value = SettingsManager.look_sensitivity
	$PanelContainer/MarginContainer/OptionsForm/Volume.grab_focus()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	resolution.visible = not button_pressed
	resolution_label.visible = not button_pressed


func _on_volume_drag_ended(_value_changed: bool) -> void:
	SettingsManager.volume = volume.value
	SettingsManager.persist()


func _on_look_sensitivity_drag_ended(_value_changed: bool) -> void:
	SettingsManager.look_sensitivity = look_sensitivity.value
	SettingsManager.persist()
