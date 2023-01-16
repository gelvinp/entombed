class_name NotableLocation
extends Marker3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(!LocationDatabase.locations.has(name))
	LocationDatabase.locations[name] = self
