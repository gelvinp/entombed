extends Node3D

@onready var gate: AnimatableBody3D = $AnimatableBody3D
@onready var area: Area3D = $Area3D
@onready var gate_audio: AudioStreamPlayer3D = $AnimatableBody3D/Gate/AudioStreamPlayer3D
@onready var reopen_audio: AudioStreamPlayer3D = $AnimatableBody3D/Gate/ReopenSound

@export var closedPosition: Vector3
@export var openPosition: Vector3

var _tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.gate_status.connect(self._gate_status)
	gate.position = openPosition
	gate.visible = false


func _gate_status(is_open: bool) -> void:
	if _tween:
		_tween.kill()
	
	if is_open:
		_tween = create_tween()
		_tween.tween_property(gate, "position", openPosition, 8.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		_tween.tween_callback(func(): gate.visible = false)
		area.monitoring = true
		reopen_audio.play()
	else:
		gate_audio.play()
		get_tree().create_timer(1.52).timeout.connect(_close_gate, CONNECT_ONE_SHOT)
		


func _close_gate() -> void:
		gate.visible = true
		_tween = create_tween()
		_tween.tween_property(gate, "position", closedPosition, 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		_tween.tween_callback(func(): EventBus.gate_shut.emit())
		_tween.tween_callback(func(): EventBus.enqueue_guidance.emit("Find a way out")).set_delay(3)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	area.set_deferred("monitoring", false)
	EventBus.player_leaving.emit()
