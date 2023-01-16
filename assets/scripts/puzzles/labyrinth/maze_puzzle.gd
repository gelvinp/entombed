extends Node3D

const TILE_SIZE = 1.5
const WALL = preload("res://assets/meshes/puzzles/labyrinth.scn")
const KEY = preload("res://assets/scenes/puzzles/key_on_pedestal.tscn")

@onready var walls_node: Node3D = $"../east_wing/MazeNavigationRegion"
@onready var nav_region: NavigationRegion3D = get_tree().get_first_node_in_group("navregion")

var key
var maze: Maze
var wall_array: Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PuzzleManager.LabyrinthReady.connect(_prepare, CONNECT_ONE_SHOT)


func _prepare(m: PuzzleManager.Maze) -> void:
	var wall_transforms: Array[Transform3D] = []
	maze = m
	
	for index in range(maze.walls.size()):
		var x = index % maze.width
		var y = index / maze.width
		var cell = maze.walls[index] as Array[PuzzleManager.Maze.D]
		
		for wall in cell:
			var wall_transform = Transform3D()
			wall_transform.origin = Vector3(x, 0, -y) * TILE_SIZE
			
			# Offsets
			match wall:
				PuzzleManager.Maze.D.N:
					wall_transform.origin += Vector3.FORWARD * TILE_SIZE
				PuzzleManager.Maze.D.E:
					wall_transform = wall_transform.rotated_local(Vector3.UP, PI / 2.0)
					wall_transform.origin += Vector3.RIGHT * TILE_SIZE
				PuzzleManager.Maze.D.W:
					wall_transform = wall_transform.rotated_local(Vector3.UP, PI / 2.0)
			
			if wall_transforms.has(wall_transform):
				continue
			
			wall_transforms.append(wall_transform)
			var instance = WALL.instantiate()
			instance.transform = wall_transform
			walls_node.add_child(instance)
			wall_array.append(instance)
	
	get_tree().create_timer(0.1).timeout.connect(nav_region.bake_navigation_mesh.bind(true), CONNECT_ONE_SHOT)
	
	key = KEY.instantiate()
	key.transform.origin = Vector3(maze.key_location.x, 0, -maze.key_location.y) * TILE_SIZE + Vector3(1, 0, -1) * TILE_SIZE * 0.5
	add_child(key)
	key.picked_up.connect(_braid)


func _braid() -> void:
	maze.braid()
	EventBus.noise_made.emit(Vector3(maze.key_location.x, 0, -maze.key_location.y) * TILE_SIZE + Vector3(1, 0, -1) * TILE_SIZE * 0.5)
	
	var wall_transforms: Array[Transform3D] = []
	
	for index in range(maze.walls.size()):
		var x = index % maze.width
		var y = index / maze.width
		var cell = maze.walls[index] as Array[PuzzleManager.Maze.D]
		
		for wall in cell:
			var wall_transform = Transform3D()
			wall_transform.origin = Vector3(x, 0, -y) * TILE_SIZE
			
			# Offsets
			match wall:
				PuzzleManager.Maze.D.N:
					wall_transform.origin += Vector3.FORWARD * TILE_SIZE
				PuzzleManager.Maze.D.E:
					wall_transform = wall_transform.rotated_local(Vector3.UP, PI / 2.0)
					wall_transform.origin += Vector3.RIGHT * TILE_SIZE
				PuzzleManager.Maze.D.W:
					wall_transform = wall_transform.rotated_local(Vector3.UP, PI / 2.0)
			
			if wall_transforms.has(wall_transform):
				continue
			
			wall_transforms.append(wall_transform)
	
	for wall in wall_array:
		if not wall_transforms.has(wall.transform):
			wall.braid()
	
	get_tree().create_timer(1.3).timeout.connect(nav_region.bake_navigation_mesh.bind(true), CONNECT_ONE_SHOT)
