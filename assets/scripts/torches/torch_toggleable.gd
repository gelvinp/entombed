class_name TorchToggleable
extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $OmniLight3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var active: bool = true:
	get:
		return active
	set(value):
		active = value
		particles.emitting = value
		light.visible = value
		audio.playing = value
