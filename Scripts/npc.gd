extends CharacterBody2D

@onready var interaction_area : InteractionArea = $InteractionArea2

@export var vision_renderer: Polygon2D
@export var alert_color: Color

@export_group("Movement")
@export var move_on_path: PathFollow2D
@export var movement_speed = 0.1

@export_group("Visuals")
@export var colors = [Color()]
@export var interact_name: String = ""
@export var is_interactable = true
@export var outline: ShaderMaterial
@export var default: ShaderMaterial

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE

var is_highlighted = false
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

func _toggle_outline():
	if is_highlighted :
		color_rect_node.material = default
		is_highlighted = false
	elif not is_highlighted and InteractionManager.can_interact :
		color_rect_node.material = outline
		is_highlighted = true
	else:
		pass

func _physics_process(delta: float) -> void:
	move_on_path.progress += movement_speed
	global_position = move_on_path.position
	rotation = move_on_path.rotation
	
	move_and_slide()

func _on_vision_cone_area_2_body_entered(body: Node2D) -> void:
	print("%s is seeing %s" % [self, body])
	vision_renderer.color = alert_color

func _on_vision_cone_area_2_body_exited(body: Node2D) -> void:
	print("%s stopped seeing %s" % [self, body])
	vision_renderer.color = original_color

func _on_interact():
	print("stolen")
