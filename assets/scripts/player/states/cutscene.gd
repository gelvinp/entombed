extends PlayerState

var _cutscenes: Array[Cutscene]
var _cutscene_index: int = -1
var _current_cutscene_index: int = -1
var _return := ""


func enter(msg := {}) -> void:
	assert(msg.has_all(["cutscenes", "return_to"]))
	assert(typeof(msg["cutscenes"]) == TYPE_ARRAY)
	assert(typeof(msg["return_to"]) == TYPE_STRING)
	
	_cutscenes = msg["cutscenes"]
	_cutscene_index = 0
	_return = msg["return_to"]
	
	player.velocity = Vector3.ZERO


func process(_delta: float) -> void:
	if _cutscene_index == _current_cutscene_index:
		return
	
	if _cutscene_index >= _cutscenes.size():
		state_machine.transition_to(_return)
		return
	
	_current_cutscene_index = _cutscene_index
	_cutscenes[_cutscene_index].run(get_tree(), func(): _cutscene_index += 1)
