class_name StoryPuzzle
extends Node3D

@onready var gates = [
	$StoryGate1,
	$StoryGate2,
	$StoryGate3
]
@onready var key: KeyInteractable = $Key
@onready var warp_point: Node3D = $WarpPoint
@onready var woosh: AudioStreamPlayer = $WooshSound

var correct_choices := 0
var able_to_solve := false


func _ready() -> void:
	PuzzleManager.StoryReady.connect(_prepare, CONNECT_ONE_SHOT)
	gates.map(func(e: StoryGate): e.entered_side.connect(self._on_entered_side))
	EventBus.book_read.connect(func(): able_to_solve = true, CONNECT_ONE_SHOT)


func _prepare(solution: Array[StoryPair]) -> void:
	for i in range(3):
		gates[i].prepare(solution[i])


func _on_entered_side(body: Node3D, correct_side: bool) -> void:
	if correct_side and able_to_solve:
		correct_choices += 1
		
		if correct_choices >= 3:
			key.enable()
			gates.map(func(e: StoryGate): e.call_deferred("disable"))
	else:
		correct_choices = 0
		woosh.play()
		(body as Player).state_machine.transition_to("CameraFade")
		await get_tree().create_timer(0.75).timeout
		body.global_position = warp_point.global_position
		gates.map(func(e: StoryGate): e.call_deferred("reset"))
		EventBus.noise_made.emit(body.global_position)
		
		if randf() < 0.25:
			EventBus.haunt_early.emit({ "slowed": true })


func _on_encounter_area_body_entered(_body: Node3D) -> void:
	EventBus.encountered_interaction = true
