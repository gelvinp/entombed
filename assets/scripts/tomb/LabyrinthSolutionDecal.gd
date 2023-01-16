extends Decal


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PuzzleManager.LabyrinthSolutionReady.connect(_prepare)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _prepare(img: ImageTexture) -> void:
	texture_albedo = img
