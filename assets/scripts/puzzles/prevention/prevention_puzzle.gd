extends Node3D

@onready var start: Node3D = $"Cauldron Start"
@onready var end: Node3D = $"Cauldron End"
@onready var ingredients = $Ingredients
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var key_path: PathFollow3D = $Path3D/PathFollow3D
@onready var key: KeyInteractable = $Path3D/PathFollow3D/Key
@onready var bubbling: AudioStreamPlayer3D = $Bubbling
@onready var submerge: AudioStreamPlayer3D = $Submerge
@onready var correct_sound: AudioStreamPlayer3D = $Correct
@onready var reset_sound: AudioStreamPlayer3D = $Reset

const INGREDIENT_COUNT = 3

var in_cauldron := 0
var potentially_correct := true
var correct_ingredients: Array[PuzzleManager.prev_Ingredient]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PuzzleManager.PreventionReady.connect(_prepare, CONNECT_ONE_SHOT)


func _prepare(solution: Array[PuzzleManager.prev_Ingredient]) -> void:
	correct_ingredients = solution


func add_ingredient(ingredient: PreventionIngredientInteractable) -> void:
	ingredients.propagate_call("disable_collision")
	
	ingredient.position = start.position
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_callback(submerge.play).set_delay(0.8)
	tween.parallel().tween_property(ingredient, "position", end.position, 1)
	
	await tween.finished
	await submerge.finished
	
	ingredient.visible = false
	
	if not correct_ingredients.has(ingredient.ingredient_type):
		potentially_correct = false
	
	in_cauldron += 1
	if in_cauldron >= INGREDIENT_COUNT:
		check_ingredients()
	
	ingredients.propagate_call("enable_collision_if_visible")


func check_ingredients() -> void:
	if potentially_correct:
		correct()
	else:
		reset()


func correct() -> void:
	correct_sound.play()
	ingredients.propagate_call("set", ["visible", false])
	key.visible = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(bubbling, "volume_db", linear_to_db(0), 3)
	tween.parallel().tween_property(key_path, "progress_ratio", 1, 3)
	particles.emitting = false
	
	await tween.finished
	key.enable()


func reset() -> void:
	reset_sound.play()
	EventBus.noise_made.emit(global_position)
	ingredients.propagate_call("reset")
	potentially_correct = true
	in_cauldron = 0
		
	if randf() < 0.25:
		print("Prevention early")
		EventBus.haunt_early.emit({ "slowed": true, "non_key": true })


func _on_encounter_area_body_entered(_body: Node3D) -> void:
	EventBus.encountered_interaction = true
