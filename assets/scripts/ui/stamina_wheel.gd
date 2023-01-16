class_name StaminaWheel
extends TextureProgressBar

## Represents the player's current stamina and exhaustion
##
## Connects to [code]stamina_percent[/code] and [code]exhausted[/code] signals
## on the [EventBus]

## The color to be displayed when not exhausted
@export var normal_color: Color

## The color to be displayed when exhausted
@export var exhausted_color: Color

## The color to be displayed when very exhausted
@export var exhausted_severe_color: Color

## The color to be displayed when the player is exhausted

@onready var timer: Timer = $Timer
var _displayed := false
var _tween: Tween = null
var _exhausted := false

const INVISIBLE := Color(1, 1, 1, 0)
const VISIBLE := Color(1, 1, 1, 1)


func _ready() -> void:
	EventBus.connect("stamina_percent", self._update_stamina_percent)
	EventBus.connect("exhausted", self._update_exhaustion)
	modulate = INVISIBLE
	tint_progress = normal_color


func _update_stamina_percent(percent: float) -> void:
	value = percent * 100
	_display()
	
	if _exhausted:
		tint_progress = exhausted_severe_color.lerp(exhausted_color, percent)
	
		# I love floating point math. it's so fun and not horrible
		if is_equal_approx(percent - 1.0, 0.0):
			_flash()
	
	elif is_equal_approx(percent - 1.0, 0.0):
		timer.start()


func _update_exhaustion() -> void:
	_exhausted = true


func _on_timer_timeout() -> void:
	_hide()


func _display():
	if _displayed:
		return
	
	_displayed = true
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate", VISIBLE, 0.5)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _hide():
	if not _displayed:
		return
	
	_displayed = false
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate", INVISIBLE, 0.5)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)


func _flash():
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	
	_tween.tween_property(self, "tint_progress", VISIBLE, 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "tint_progress", normal_color, 0.2)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	_tween.tween_callback(timer.start)
	
	_exhausted = false
