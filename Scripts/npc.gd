extends CharacterBody2D

@export var colors = [Color()]
@export var interact_name: String = ""
@export var is_interactable = true

var interact: Callable = func():
	pass

func _ready() -> void:
	randomize()
	modulate = colors[randi() % colors.size()]
