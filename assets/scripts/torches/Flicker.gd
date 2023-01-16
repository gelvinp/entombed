extends OmniLight3D


@onready var noise = FastNoiseLite.new()
var val = 0.0
const MAX_VAL = 100_000_000

func _ready() -> void:
	val = randi() % MAX_VAL
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH


func _process(_delta: float) -> void:
	val += 0.5
	if val > MAX_VAL:
		val = 0.0
	
	light_energy = ((noise.get_noise_1d(val) + 1) / 4.0) + 0.5
