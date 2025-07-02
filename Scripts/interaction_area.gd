extends Area2D

class_name InteractionArea

@onready var player = get_tree().get_first_node_in_group("Player")

@export var interaction_name: String 
@export var npc: CharacterBody2D

var can_interact = true
var active_areas = InteractionManager.active_areas
var label = InteractionManager.label

const base_text = "Steal (Left Click)"

var interact: Callable = func():
	pass

func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		label.text = base_text
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 24
		label.global_position.x -= label.size.x / 2.5
		label.show()
	else:
		label.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Confirm") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()

func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)
	npc._toggle_outline()

func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)
	npc._toggle_outline()
