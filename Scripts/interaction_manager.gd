extends Node2D

@onready var label = $Label
@onready var interaction_area = InteractionArea

var active_areas = []

const base_text = "Steal (Left Click)"

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	active_areas.erase(area)
