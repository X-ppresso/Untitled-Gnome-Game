extends CharacterBody2D

@export var colors = [Color()]
@export var interact_name: String = ""
@export var is_interactable = true
@export var outline: ShaderMaterial
@export var default: ShaderMaterial
var mouse_is_hovering = false

@onready var color_rect_node = $NPC

var interact: Callable = func():
	pass

func _ready() -> void:
	randomize()
	modulate = colors[randi() % colors.size()]
	$NPC.play("idle")

func toggle_outline():
	color_rect_node.material = outline
	
