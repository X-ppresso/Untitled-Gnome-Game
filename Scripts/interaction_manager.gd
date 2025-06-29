extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var label = $Label

const base_text = ""

var active_areas = []
var can_interact = true

func register_area(area: InteractionArea):
	active_areas.push_back(area)
	active_areas.sort_custom(_sort_by_distance_to_player)

func unregister_area(area: InteractionArea):
	active_areas.erase(area)
	active_areas.sort_custom(_sort_by_distance_to_player)

func _process(delta: float) -> void:
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].interaction_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 24
		label.global_position.x -= label.size.x / 2.5
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_squared_to(area1.global_position)
	var area2_to_player = player.global_position.distance_squared_to(area2.global_position)
	return area1_to_player > area2_to_player

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Confirm") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
