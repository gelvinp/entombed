extends Node

var locations := {}


func gpos_of(location: String) -> Vector3:
	assert(locations.has(location))
	return locations[location].global_position
