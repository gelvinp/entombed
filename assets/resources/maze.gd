class_name Maze
extends Resource

enum D
{
	N = 1,
	S = 2,
	E = 4,
	W = 8
}

const DX = {
	D.E: 1, D.W: -1, D.N: 0, D.S: 0
}

const DY = {
	D.N: 1, D.S: -1, D.E: 0, D.W: 0
}

const OPPOSITE = {
	D.E: D.W, D.W: D.E, D.N: D.S, D.S: D.N
}

var width: int
var height: int

var grid: Array
var walls: Array

var key_location: Vector2i


func generate(w: int, h: int) -> void:
	width = w
	height = h
	
	grid = Array()
	grid.resize(w  * h)
	grid.fill(0)
	
	carve_from(0, 0)
	create_entrance()
	create_goal()
	walls = grid.map(get_walls)


func carve_from(x: int, y: int) -> void:
	var directions = [D.N, D.S, D.E, D.W]
	directions.shuffle()
	
	for direction in directions:
		if remove_wall(x, y, direction):
			var nx = x + DX[direction]
			var ny = y + DY[direction]
			carve_from(nx, ny)


func remove_wall(x: int, y: int, direction: D, only_if_fresh: bool = true) -> bool:
	var nx = x + DX[direction]
	var ny = y + DY[direction]
	var n = ny * width + nx
	
	if (
		nx >= 0 and 
		nx < width and 
		ny >= 0 and
		ny < height and
		(grid[n] == 0 or not only_if_fresh)
	):
		grid[y * width + x] |= direction
		grid[n] |= OPPOSITE[direction]
		
		return true
	else:
		return false


func braid() -> void:
	for index in range(grid.size()):
		var cell = grid[index]
		var cell_walls = get_walls(cell)
		
		if cell_walls.size() <= 2:
			continue
		
		var preferred = []
		
		if cell_walls.has(D.E):
			preferred.append(D.E)
		if cell_walls.has(D.W):
			preferred.append(D.W)
		
		preferred.shuffle()
		
		if cell_walls.has(D.N):
			preferred.append(D.N)
		if cell_walls.has(D.S):
			preferred.append(D.S)
		
		while preferred.size() > 0:
			var to_remove = preferred.pop_front()
			
			var x = index % width
			var y = index / width
			if remove_wall(x, y, to_remove, false):
				break
	
	walls = grid.map(get_walls)


func create_entrance() -> void:
	grid[width] |= D.W


func create_goal() -> void:
	key_location = Vector2i(randi_range(3, width - 1), height - 1)


func get_walls(cell: int) -> Array[D]:
	var edges: Array[D] = []
	var directions = [D.N, D.S, D.E, D.W]
	
	for direction in directions:
		if (cell & direction) == 0:
			edges.append(direction)
	
	return edges


func get_solution() -> ImageTexture:
	var image = Image.create(width * 2 + 1, height * 2 + 1, false, Image.FORMAT_L8)
	image.fill(Color(0.5, 0.5, 0.5, 1))
	
	for index in range(grid.size()):
		var x = 1 + 2 * (index % width)
		var y = 1 + 2 * (index / width)
		var cell = grid[index]
		
		image.set_pixel(x, y, Color(0.09, 0.09, 0.09, 1))
		
		var directions = [D.N, D.S, D.E, D.W]
		for direction in directions:
			if (cell & direction) == 0:
				continue
			
			var px = x + DX[direction]
			var py = y + DY[direction]
			
			image.set_pixel(px, py, Color(0.09, 0.09, 0.09, 1))
		
		# Check corners
		if (cell & D.N) and (cell & D.E):
			image.set_pixel(x + 1, y + 1, Color(0.09, 0.09, 0.09, 1))
		if (cell & D.S) and (cell & D.E):
			image.set_pixel(x + 1, y - 1, Color(0.09, 0.09, 0.09, 1))
		if (cell & D.N) and (cell & D.W):
			image.set_pixel(x - 1, y + 1, Color(0.09, 0.09, 0.09, 1))
		if (cell & D.S) and (cell & D.W):
			image.set_pixel(x - 1, y - 1, Color(0.09, 0.09, 0.09, 1))
	
	image.set_pixelv((key_location * 2) + Vector2i.ONE, Color(0.8, 0.8, 0.8, 1))
	
	image.flip_y()
	image.resize(325, 475, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)
