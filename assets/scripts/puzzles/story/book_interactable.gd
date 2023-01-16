class_name BookInteractable
extends Interactable


func get_mouseover_text() -> String:
	return "Read the book"


func interact() -> void:
	EventBus.book_read.emit()
