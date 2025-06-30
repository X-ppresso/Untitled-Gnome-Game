extends Area2D

class_name InteractionArea

@export var interaction_name: String 
@export var npc: CharacterBody2D

var interact: Callable = func():
	pass

func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)
	npc._toggle_outline()

func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
	npc._toggle_outline()
