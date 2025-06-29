extends CharacterBody2D

@onready var interaction_area : InteractionArea = $InteractionArea2

@export var wander_direction : Node2D
@export var colors = [Color()]
@export var interact_name: String = ""
@export var is_interactable = true
@export var outline: ShaderMaterial
@export var default: ShaderMaterial

var mouse_is_hovering = false

@export var walk_speed: float 

@onready var color_rect_node = $NPC

var interact: Callable = func():
	pass

func _ready() -> void:
	randomize()
	modulate = colors[randi() % colors.size()]
	$NPC.play("idle")
	interaction_area.interact = Callable(self, "_on_interact")

func toggle_outline():
	color_rect_node.material = outline
	

func _physics_process(delta: float) -> void:
	velocity = wander_direction.direction * walk_speed
	
	move_and_slide()

func _on_interact():
	pass
