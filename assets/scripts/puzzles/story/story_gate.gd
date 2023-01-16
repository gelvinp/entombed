class_name StoryGate
extends Node3D

signal entered_side(body: Node3D, correct_side: bool)

@onready var left_decal: Decal = $LeftDecal
@onready var right_decal: Decal = $RightDecal

@onready var left_area: Area3D = $LeftArea
@onready var right_area: Area3D = $RightArea

@onready var fog: FogVolume = $FogVolume

var is_left_correct := false


func prepare(pair: StoryPair) -> void:
	is_left_correct = pair.is_first_choice
	
	left_decal.texture_albedo = pair.first_choice
	right_decal.texture_albedo = pair.second_choice


func _entered_side(body: Node3D, entered_left_side: bool) -> void:
	entered_side.emit(body, entered_left_side == is_left_correct)


func reset() -> void:
	if left_area.body_entered.get_connections().size() == 0:
		left_area.body_entered.connect(_entered_side.bind(true), CONNECT_ONE_SHOT)
	if right_area.body_entered.get_connections().size() == 0:
		right_area.body_entered.connect(_entered_side.bind(false), CONNECT_ONE_SHOT)
	


func disable() -> void:
	left_area.monitoring = false
	right_area.monitoring = false
	
	var tween = create_tween()
	tween.tween_property(fog.material, "density", 0, 3)
	tween.tween_callback(func(): fog.visible = false)
