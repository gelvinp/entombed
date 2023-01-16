class_name WaitForCutscene
extends Cutscene

@export var duration: float


func run(scene_tree: SceneTree, finished: Callable) -> void:
	await scene_tree.create_timer(duration).timeout
	finished.call()
