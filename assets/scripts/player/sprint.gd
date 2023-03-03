class_name Sprint
extends Node

## A utility class to manage the players ability to sprint
##
## Allows the user to query whether or not the player is sprinting or cooling
## down, as well as get the remaining percentage of their sprint stamina or
## regeneration.
##
## Connects to [code]stamina_percent[/code] and [code]exhausted[/code] signals
## on the [EventBus]

## Time that player is able to sprint for
@export_range(0, 10) var sprint_time: float

## Time the player must take to recover after exhausting their [member sprint_time]
@export_range(0, 10) var cooldown_time: float

## Whether or not the player currently intends to sprint
var sprinting: bool:
	get:
		return _sprinting

## Whether or not the player is currently exhausted
var exhausted: bool:
	get:
		return _cooldown_active

## The percentage of the players sprint stamina remaining.
## In the range [code][0, 1][/code]
var sprint_remaining_percent: float:
	get:
		return clampf(_sprint_available / sprint_time, 0.0, 1.0)

## The percentage of the players exhaustion time remaining.
## In the range [code][0, 1][/code]
var cooldown_remaining_percent: float:
	get:
		var total := _cooldown_timer.wait_time
		var left := _cooldown_timer.time_left
		var passed := total - left
		
		return clampf(passed / total, 0.0, 1.0)

## A CharacterBody3D to optionally check for movement for sprint intent
var character_target: CharacterBody3D = null

## Emitted when the player starts sprinting
signal sig_sprinting

## Emitted when the player becomes exhausted
signal sig_exhausted

## Emitted when the player returns to normal speed
signal sig_walking

@onready var _sprint_available := sprint_time:
	get:
		return _sprint_available
		
	set(value):
		if value < 0:
			_cooldown_active = true
			_cooldown_timer.start()
			EventBus.exhausted.emit()
		
		_sprint_available = value


@onready var _cooldown_timer: Timer = $Timer
var _sprinting := false:
	get:
		return _sprinting
	set(value):
		if value != _sprinting:
			if value:
				sig_sprinting.emit()
			elif not _cooldown_active:
				sig_walking.emit()
		
		_sprinting = value

var _cooldown_active := false:
	get:
		return _cooldown_active
	set(value):
		if value != _cooldown_active and value:
			sig_exhausted.emit()
		
		_cooldown_active = value

var infinite_sprint := false


func _ready() -> void:
	_cooldown_timer.wait_time = cooldown_time
	EventBus.player_entered_region.connect(func(region: EventBus.REGION): infinite_sprint = region == EventBus.REGION.BURIAL_CHAMBER)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var sprint_intent = Input.is_action_pressed("sprint")
	if character_target:
		sprint_intent = sprint_intent and character_target.velocity.length_squared() > 0
	
	if sprint_intent and infinite_sprint:
		_sprinting = true
		return
	elif sprint_intent and _sprint_available >= 0:
		# Player wants to, and is able to, sprint
		_sprinting = true
		_sprint_available -= delta
		EventBus.stamina_percent.emit(sprint_remaining_percent)
	else:
		# Player is not trying or, or is unable to, sprint
		_sprinting = false
		
		if (
			not _cooldown_active and
			not sprint_intent and
			_sprint_available < 0
		):
			# Player is no longer exhausted, not trying to sprint, and has
			# not yet recovered. They should recover at this point.
			_sprint_available = sprint_time
		elif _sprint_available >= 0 and _sprint_available < sprint_time:
			# Player stopped sprinting before becoming exhausted, and should
			# recover their stamina in real time
			_sprint_available = min(_sprint_available + delta, sprint_time)
			EventBus.stamina_percent.emit(sprint_remaining_percent)
		elif _cooldown_active:
			# Player is currently exhausted
			EventBus.stamina_percent.emit(cooldown_remaining_percent)


func _on_timer_timeout() -> void:
	_cooldown_active = false
	sig_walking.emit()
	EventBus.stamina_percent.emit(1.0)
