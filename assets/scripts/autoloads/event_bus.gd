extends Node

## Global event bus
##
## Facilitates communication between the game and the UI

## Signals when the current percent of the players stamina or exhaustion changes
signal stamina_percent(percent: float)

## Signals when the players exhaustion status changes
signal exhausted()

## Signals when a scene change should occur
signal scene_change(scene_path: String)
signal scene_change_with_message(scene_path: String, message: Dictionary)

## Signals whether or not the gate should open
signal gate_status(is_open: bool)

## Signals that the gate has slammed down
signal gate_shut

## Signals when the player has first entered the tomb
signal player_entering

## Signals when the player has entered the tunnel after opening the gate
signal player_leaving

## Signals when the player is looking at a new interactable
signal interactable_changed(interactable: Interactable)

## Signals when the number of keys collected has changed
signal keys_collected_changed(keys: int)

## Adds guidance to the qeueu
signal enqueue_guidance(guidance: String)

## Signals when the story puzzle should become solvable
signal book_read

## Signals when the player has stopped reading the book
signal book_closed

## Signals when the burial chamber is navigation-accessable
signal burial_chamber_accessable

## Signals when the burial mound starts and finishes burning
signal mound_burn_start
signal mound_burn_end

## Signals that the haunt should start early
signal haunt_early(flags: Dictionary)

## Signals when the player has made a noise
signal noise_made(at_position: Vector3)

enum REGION
{
	CENTRAL_CHAMBER,
	STORY_PUZZLE,
	MAZE_PUZZLE,
	MURAL,
	BRIDGE_PUZZLE,
	PREVENTION_PUZZLE,
	BURIAL_CHAMBER
}

signal player_entered_region(region: REGION)

signal in_danger(danger: bool)

signal player_death

var player_region: REGION = REGION.CENTRAL_CHAMBER:
	get:
		return player_region
	set(value):
		if value != player_region:
			player_region = value
			player_entered_region.emit(value)


var keys_collected: int = 0:
	get:
		return keys_collected
	set(value):
		keys_collected = value
		if keys_collected > 0:
			keys_collected_changed.emit(value)
		if keys_collected == 4:
			_its_time()

var encountered_interaction := false:
	get:
		return encountered_interaction
	set(value):
		if value and not encountered_interaction:
			enqueue_guidance.emit("Use the %s button to interact" % InputManager.Interact)
		
		encountered_interaction = value


var is_in_danger := false


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	in_danger.connect(func(danger: bool): is_in_danger = danger)


func reset() -> void:
	player_region = REGION.CENTRAL_CHAMBER
	keys_collected = 0
	encountered_interaction = false
	is_in_danger = false


func _its_time() -> void:
	enqueue_guidance.emit("[color=red]It's time. Go to the burial chamber.\nDestroy him before he destroys you.[/color]")
	var audio = AudioStreamPlayer.new()
	audio.stream = preload("res://assets/sounds/enemy_scream.ogg")
	audio.bus = "Reverb"
	audio.pitch_scale = 0.8
	add_child(audio)
	audio.play()
	await audio.finished
	audio.queue_free()
