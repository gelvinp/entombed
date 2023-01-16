extends Control

@export var guidance_time := 1.0

@onready var label: Label = $Label
@onready var guidance: RichTextLabel = $Guidance

var guidance_queue: Array[String] = []
var guidance_displayed := false

func _ready() -> void:
	EventBus.interactable_changed.connect(_on_interactable_changed)
	EventBus.enqueue_guidance.connect(_enqueue_guidance)
	EventBus.book_read.connect(func(): self.visible = false)
	EventBus.book_closed.connect(func(): self.visible = true)


func _on_interactable_changed(interactable: Interactable) -> void:
	if interactable == null:
		label.text = ""
	else:
		label.text = interactable.get_mouseover_text()


func _enqueue_guidance(text: String) -> void:
	guidance_queue.append(text)
	
	if not guidance_displayed:
		_show_guidance()


func _show_guidance() -> void:
	if guidance_queue.size() == 0:
		return
	
	guidance_displayed = true
	
	var text: String = guidance_queue.pop_front()
	
	guidance.modulate = Color(1, 1, 1, 0)
	guidance.text = "[center]%s[/center]" % [text]
	
	var tween = create_tween()
	tween.tween_property(guidance, "modulate", Color(1, 1, 1, 1), 1)
	tween.tween_property(guidance, "modulate", Color(1, 1, 1, 0), 1).set_delay(guidance_time)
	
	await tween.finished
	
	if guidance_queue.size() > 0:
		call_deferred("_show_guidance")
	else:
		guidance_displayed = false
