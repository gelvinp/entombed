extends Node3D

@onready var bridge_near: BridgeRotater = $BridgeNearBody
@onready var bridge_center: BridgeRotater = $BridgeCenterBody
@onready var bridge_far: BridgeRotater = $BridgeFarBody
@onready var bridge_fork: BridgeRotater = $BridgeForkBody

@onready var switch_1: BridgeSwitch = $Switch1
@onready var switch_2: BridgeSwitch = $Switch2
@onready var switch_3: BridgeSwitch = $Switch3
@onready var switch_4: BridgeSwitch = $Switch4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bridge_positions = Vector4i()
	
	while is_solved(bridge_positions):
		bridge_positions += bridge_array_to_vec(switch_1.bridges) * randi_range(0, 9)
		bridge_positions += bridge_array_to_vec(switch_2.bridges) * randi_range(0, 9)
		bridge_positions += bridge_array_to_vec(switch_3.bridges) * randi_range(0, 9)
		bridge_positions += bridge_array_to_vec(switch_4.bridges) * randi_range(0, 9)
	
	if (bridge_positions.x % 2) != 0:
		bridge_near.toggle(false)
	if (bridge_positions.y % 2) != 0:
		bridge_center.toggle(false)
	if (bridge_positions.z % 2) != 0:
		bridge_far.toggle(false)
	if (bridge_positions.w % 2) != 0:
		bridge_fork.toggle(false)


func bridge_array_to_vec(arr: Array[BridgeRotater]) -> Vector4i:
	return Vector4i(
		1 if arr.has(bridge_near) else 0,
		1 if arr.has(bridge_center) else 0,
		1 if arr.has(bridge_far) else 0,
		1 if arr.has(bridge_fork) else 0
	)


func is_solved(state: Vector4i) -> bool:
	return (state.x % 2) == 0 and (state.y % 2) == 0 and (state.z % 2) == 0


func _on_encounter_area_body_entered(_body: Node3D) -> void:
	EventBus.encountered_interaction = true
