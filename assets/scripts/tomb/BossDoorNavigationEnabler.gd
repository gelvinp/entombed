extends NavigationRegion3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.burial_chamber_accessable.connect(func(): enabled = true, CONNECT_ONE_SHOT)
