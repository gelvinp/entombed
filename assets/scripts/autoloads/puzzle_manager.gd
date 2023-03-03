extends Node

## Prevention Puzzle
enum prev_Ingredient
{
	SCISSORS,
	NEEDLE,
	STAKE,
	CROSS,
	STRAW
}

signal PreventionReady(solution: Array[prev_Ingredient])

var prev_Solution: Array[prev_Ingredient]

func _prepare_prevention() -> void:
	var choices = prev_Ingredient.keys()
	choices.shuffle()
	choices = choices.map(func(choice: String) -> prev_Ingredient: return prev_Ingredient[choice])
	prev_Solution = [choices[0], choices[1], choices[2]]
	PreventionReady.emit(prev_Solution)


## Story Puzzle
var story_pairs: Array[StoryPair] = [
	preload("res://assets/resources/story pairs/swirl.tres"),
	preload("res://assets/resources/story pairs/man.tres"),
	preload("res://assets/resources/story pairs/bird.tres"),
	preload("res://assets/resources/story pairs/naught.tres"),
	preload("res://assets/resources/story pairs/rune.tres")
]

signal StoryReady(pairs: Array[StoryPair])

func _prepare_story() -> void:
	story_pairs.shuffle()
	story_pairs.resize(3)
	story_pairs.map(func(e: StoryPair): e.prepare())
	StoryReady.emit(story_pairs)


## Labyrinth Puzzle
const Maze = preload("res://assets/resources/maze.gd")
var labyrinth: Maze

var lab_Solution: ImageTexture

signal LabyrinthReady(maze: Maze)
signal LabyrinthSolutionReady(solution: ImageTexture)


func _prepare_labyrinth() -> void:
	labyrinth = Maze.new()
	labyrinth.generate(6, 10)
	LabyrinthReady.emit(labyrinth)
	lab_Solution = labyrinth.get_solution()
	LabyrinthSolutionReady.emit(lab_Solution)


func prepare() -> void:
	_prepare_prevention()
	_prepare_story()
	_prepare_labyrinth()
