extends Decal

const TEXTURES = {
	PuzzleManager.prev_Ingredient.SCISSORS: preload("res://assets/textures/puzzles/prev_scissors.png"),
	PuzzleManager.prev_Ingredient.NEEDLE: preload("res://assets/textures/puzzles/prev_needle.png"),
	PuzzleManager.prev_Ingredient.STAKE: preload("res://assets/textures/puzzles/prev_stake.png"),
	PuzzleManager.prev_Ingredient.CROSS: preload("res://assets/textures/puzzles/prev_cross.png"),
	PuzzleManager.prev_Ingredient.STRAW: preload("res://assets/textures/puzzles/prev_straw.png"),
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PuzzleManager.PreventionReady.connect(_prepare)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _prepare(solution: Array[PuzzleManager.prev_Ingredient]) -> void:
	var image = Image.create(1536, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	for i in range(3):
		var tex2d = TEXTURES[solution[i]]
		image.blit_rect(tex2d.get_image(), Rect2i(Vector2i.ZERO, tex2d.get_size()), Vector2i(512 * i, 0))
	
	texture_albedo = ImageTexture.create_from_image(image)
