class_name StoryPair
extends Resource

@export var first_choice: Texture2D
@export var second_choice: Texture2D

var is_first_choice: bool = true

var correct_choice: Texture2D:
	get:
		return first_choice if is_first_choice else second_choice

var incorrect_choice: Texture2D:
	get:
		return second_choice if is_first_choice else first_choice


func prepare() -> void:
	is_first_choice = ((randi() % 2) == 0)
