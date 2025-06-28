extends CharacterBody2D

# Movement speed of the character in pixels per second.
@export var speed = 200

# How quickly the character speeds up. Higher values are more responsive.
@export var acceleration = 10

# How quickly the character slows down. Higher values mean less sliding.
@export var friction = 10

@onready var interaction_area: Area2D = $Steal # Path to player's steal range
@onready var mouse_ray_cast: RayCast2D = $MouseRayCast 

var _interactable_npcs: Array[Node] = [] # Stores NPCs currently in range
var _hovered_npc: Node = null # NEW: Stores the NPC currently under the mouse

func _on_steal_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_steal_body_exited(body: Node2D) -> void:
	pass # Replace with function body.

#movement stuff
func _physics_process(delta: float) -> void:
	# Handle player movement
	var direction = Input.get_vector("left", "right", "up", "down")
	var is_moving = direction.length() > 0
	
	# Set the target velocity based on input and speed.
	var target_velocity: Vector2 = direction * speed

	if Input.is_action_pressed("run") and is_moving and not is_placing_distraction: 
		$Dobby_anim.play("run")
		$disguise.play("run")
	elif is_moving and not is_placing_distraction: # Check if any directional input is being pressed
		$Dobby_anim.play("walk")
		$disguise.play("walk")
	elif is_placing_distraction:
		$Dobby_anim.play("cast")
	else:
		$Dobby_anim.play("idle") # Stop animation if no relevant input
		$disguise.play("idle")
	
	
	# Smooth the velocity using lerp.
	velocity = lerp(velocity, target_velocity, acceleration * delta)
	
	if Input.is_action_pressed("run"):
		speed = 175
	else: 
		speed =100
	
	move_and_slide()
	
	#biar nggak kecepeten klo jalan diagonal
	if direction.length() > 1.0:
		direction = direction.normalized()
	if is_placing_distraction == true :
		speed = 0
	
	# Make the character look at the mouse cursor
	look_at(get_global_mouse_position())

@export var distraction_dummy_scene: PackedScene # Assign your DistractionDummy.tscn here
@export var placement_camera_scene: PackedScene # A separate Camera2D scene for placement
@export var placement_range: float = 120.0 # Max pixel distance to place the dummy
@export var distraction_duration: float = 10.0 # How long the dummy lasts (in seconds)

var illusion_in_cooldown: bool = false
var disguise_in_cooldown: bool = false
var is_placing_distraction: bool = false
var is_in_disguise: bool = false
var preview_dummy: Node2D = null
var placement_camera: Camera2D = null
var original_camera: Camera2D = null # Store a reference to the player's normal camera

@onready var player_movement_component: Node = null
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# Get a reference to the player's default camera
	original_camera = $Dobbycam # Replace with the actual path to your player's Camera2D
	
	player_movement_component = self
	
	 # Connect signals from the InteractionArea
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	
	 # Mouse RayCast2D setup
	mouse_ray_cast.enabled = true # Keep it enabled always to detect hover
	# Its position will be updated every frame in _process or _physics_process
	# Its collision mask should detect only NPCs (Layer 4)
	mouse_ray_cast.collision_mask = (1 << 3) # Assuming Layer 4 is NPCs (1 << (4-1))
	
func _input(event):
	if event.is_action_pressed("Ability_1") and not is_placing_distraction and not illusion_in_cooldown and not is_in_disguise:
		start_placement_mode()
	elif event.is_action_pressed("Ability_1") and illusion_in_cooldown:
		print("sabar ajg")
	elif event.is_action_pressed("Ability_1") and is_in_disguise:
		print("tak bole campur skill bang hehe")
	elif is_placing_distraction:
		if event.is_action_pressed("Confirm"):
			confirm_placement()
		elif event.is_action_pressed("Cancel"):
			end_placement_mode()
	if event.is_action_pressed("Ability_2") and not is_placing_distraction and not disguise_in_cooldown:
		enter_disguise_mode()
		
	if event.is_action_pressed("Confirm"):
		pass
		
	if event.is_action_pressed("Pause"):
		$"../Pause".pause()
	
	#if event.is_action_pressed("Ability_2") and not is_placing_distraction:
		#start_disguise()

func _process(delta):
	if is_placing_distraction:
		update_placement_preview()
		handle_placement_camera_movement(delta)
		
 
func _on_interaction_area_body_entered(body: Node2D):
	if body.is_in_group("NPC"):
		if not _interactable_npcs.has(body):
			_interactable_npcs.append(body)
			print("NPC entered interaction range: ", body.name)
			# You might update a UI prompt if this NPC is also hovered

func _on_interaction_area_body_exited(body: Node2D):
	if body.is_in_group("NPC"):
		if _interactable_npcs.has(body):
			_interactable_npcs.erase(body)
			print("NPC exited interaction range: ", body.name)


var player_start_placement_pos: Vector2

func start_placement_mode():
	is_placing_distraction = true
	
	$Dobby_anim.play("cast")
	
	player_start_placement_pos = global_position # Your player's actual global position
	
	#get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Hide and capture mouse for camera movement
	
	# 1. Hide player's normal camera and activate placement camera
	original_camera.enabled = false # Deactivate player camera
	
	placement_camera = placement_camera_scene.instantiate()
	get_tree().root.add_child(placement_camera)
	placement_camera.global_position = original_camera.global_position # Start at player's camera position
	placement_camera.enabled = true # Activate placement camera

	# 2. Instantiate preview dummy
	preview_dummy = distraction_dummy_scene.instantiate()
	get_tree().root.add_child(preview_dummy)
	# Make preview dummy non-collidable and potentially transparent/ghostly
	if preview_dummy.has_method("set_preview_mode"):
		preview_dummy.set_preview_mode(true) # A custom method you'll add to DistractionDummy.gd
	

func update_placement_preview():
	if not is_instance_valid(preview_dummy): return

# The preview dummy is always centered relative to the placement camera
	# Set its position to the camera's global position.
	preview_dummy.global_position = placement_camera.global_position

	 # Check placement validity using the preview_dummy's Area2D overlap detection
	var has_obstacle_overlap = preview_dummy.is_overlapping_obstacle()

	# Check if within placement range from the player's actual position
	var player_global_pos = global_position # Your player's actual global position
	var distance_to_player = player_global_pos.distance_to(preview_dummy.global_position)
	var is_in_range = distance_to_player <= placement_range

	var can_place = is_in_range and not has_obstacle_overlap # Valid if in range AND no obstacles

	# Update preview material based on placement validity
	if can_place:
		preview_dummy.set_valid_placement_material()
	else:
		preview_dummy.set_invalid_placement_material()

# handle_placement_camera_movement(delta) remains the same as it moves the camera (and thus the dummy preview)

func handle_placement_camera_movement(delta):
	if not is_instance_valid(placement_camera): return

	var camera_move_speed = 150.0 # Adjust pixels per second
	var move_direction = Vector2.ZERO

	# WASD movement for camera
	if Input.is_action_pressed("up"): move_direction.y -= 1
	if Input.is_action_pressed("down"): move_direction.y += 1
	if Input.is_action_pressed("left"): move_direction.x -= 1
	if Input.is_action_pressed("right"): move_direction.x += 1

	var current_camera_pos = placement_camera.global_position
	var new_camera_pos = current_camera_pos + move_direction.normalized() * camera_move_speed * delta

	# --- CLAMPING TO A CIRCULAR RANGE ---
	var vector_from_player_start = new_camera_pos - player_start_placement_pos
	var current_distance = vector_from_player_start.length()

	if current_distance > placement_range: # Use your existing placement_range variable
		# Normalize the vector, scale it by the max range, and add back player's start pos
		new_camera_pos = player_start_placement_pos + vector_from_player_start.normalized() * placement_range

	placement_camera.global_position = new_camera_pos

func confirm_placement():
	if not is_instance_valid(preview_dummy):
		print("No preview dummy to place.")
		return

	
	# Re-check placement validity before confirming
	var has_obstacle_overlap = preview_dummy.is_overlapping_obstacle()
	var player_global_pos = global_position
	var distance_to_player = player_global_pos.distance_to(preview_dummy.global_position)
	var is_in_range = distance_to_player <= placement_range

	if is_in_range and not has_obstacle_overlap:
		var actual_dummy = distraction_dummy_scene.instantiate()
		get_tree().root.add_child(actual_dummy)
		actual_dummy.global_position = preview_dummy.global_position # Place at preview's final position
		
		actual_dummy.set_preview_mode(false) # Reset from preview mode
		actual_dummy.start_distraction(distraction_duration)
		illusion_in_cooldown = true
		$"Illusion cooldown".start()
		end_placement_mode()
	else:
		print("Cannot place dummy here (out of range or invalid surface).")

func end_placement_mode():
	is_placing_distraction = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) # Restore mouse visibility

	if is_instance_valid(preview_dummy):
		preview_dummy.queue_free() # Remove preview dummy
		preview_dummy = null

	if is_instance_valid(placement_camera):
		placement_camera.enabled = false # Deactivate placement camera
		placement_camera.queue_free() # Remove placement camera
		placement_camera = null
	
	if is_instance_valid(original_camera):
		original_camera.enabled = true # Reactivate player's normal camera

func _on_illusion_cooldown_timeout() -> void:
	illusion_in_cooldown = false

func enter_disguise_mode():
	is_in_disguise = true
	disguise_in_cooldown = true
	$Dobby_anim.visible = false
	$disguise.visible = true
	$"Disguise timer".start()
	$"Disguise cooldown".start()

func exit_disguise_mode():
	is_in_disguise = false
	$Dobby_anim.visible = true
	$disguise.visible = false
	$"../Game_Over".game_over()

func _on_disguise_timer_timeout() -> void:
	exit_disguise_mode()

func _on_disguise_cooldown_timeout() -> void:
	disguise_in_cooldown = false
