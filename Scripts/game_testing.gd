extends Node2D

@onready var transition = $Transition

func _ready() -> void:
	transition.play("fade_in")
