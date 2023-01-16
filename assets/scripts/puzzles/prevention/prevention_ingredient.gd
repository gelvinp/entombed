class_name PreventionIngredientInteractable
extends Interactable

@export var ingredient_type: PuzzleManager.prev_Ingredient

@onready var _initial_position := position


func get_mouseover_text() -> String:
	return "Add the " + str(name) + " to the cauldron"


func interact() -> void:
	set("collision_layer", 0)
	owner.add_ingredient(self)


func reset() -> void:
	position = _initial_position
	visible = true
	set("collision_layer", 4)
	#set("monitorable", true)


func disable_collision() -> void:
	set("collision_layer", 0)


func enable_collision_if_visible() -> void:
	if visible:
		set("collision_layer", 4)
