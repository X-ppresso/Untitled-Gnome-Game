extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var label = $Label

const base_text = ""

var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	active_areas.erase(area)

func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		label.text = base_text + active_areas[0].interaction_name
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
