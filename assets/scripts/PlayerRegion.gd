extends Area3D


@export var region: EventBus.REGION


func _ready() -> void:
	body_entered.connect(func(_b: Node3D): EventBus.player_region = region)
