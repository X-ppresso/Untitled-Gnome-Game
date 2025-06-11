extends CharacterBody2D

# Movement speed of the character in pixels per second.
@export var speed = 200

# multiplier speed klo lari
@export var run_speed_multiplier = 1.75

# How quickly the character speeds up. Higher values are more responsive.
@export var acceleration = 10

# How quickly the character slows down. Higher values mean less sliding.
@export var friction = 10

#movement stuff
func _physics_process(delta: float) -> void:
	# Handle player movement
	var direction = Input.get_vector("left", "right", "up", "down")
	var is_moving = direction.length() > 0
	
	# Set the target velocity based on input and speed.
	var target_velocity: Vector2 = direction * speed

	if Input.is_action_pressed("run") and is_moving: 
		$AnimatedSprite2D.play("run")
	elif is_moving: # Check if any directional input is being pressed
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.stop() # Stop animation if no relevant input
	
	
	# Smooth the velocity using lerp.
	velocity = lerp(velocity, target_velocity, acceleration * delta)
	
	if Input.is_action_pressed("run"):
		speed = 250
	else: 
		speed =100
	
	move_and_slide()
	
	#biar nggak kecepeten klo jalan diagonal
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	# Make the character look at the mouse cursor
	look_at(get_global_mouse_position())

@export var distraction_dummy_scene: PackedScene # Assign your DistractionDummy.tscn here
@export var placement_camera_scene: PackedScene # A separate Camera2D scene for placement
@export var placement_range: float = 300.0 # Max pixel distance to place the dummy
@export var distraction_duration: float = 10.0 # How long the dummy lasts (in seconds)

var is_placing_distraction: bool = false
var preview_dummy: Node2D = null
var placement_camera: Camera2D = null
var original_camera: Camera2D = null # Store a reference to the player's normal camera

@onready var player_movement_component: Node = null
@onready var ray_cast: RayCast2D = $RayCast2D

func _ready():
	# Get a reference to the player's default camera
	original_camera = $Dobbycam # Replace with the actual path to your player's Camera2D
	
	player_movement_component = self
	
	# Initialize RayCast2D properties directly on the @onready variable
	ray_cast.enabled = false # Disable initially
	ray_cast.target_position = Vector2(0, 1) # Default cast downwards, will be updated to mouse position
	# (Optional) Set up collision masks in the editor for the RayCast2D, or here:
	# ray_cast.collision_mask = YOUR_WALL_AND_GROUND_LAYERS

func _input(event):
	if event.is_action_pressed("Ability_1") and not is_placing_distraction:
		start_placement_mode()
	elif is_placing_distraction:
		if event.is_action_pressed("Confirm"):
			confirm_placement()
		elif event.is_action_pressed("Cancel"):
			cancel_placement()

func _process(delta):
	if is_placing_distraction:
		update_placement_preview()
		handle_placement_camera_movement(delta)

func start_placement_mode():
	is_placing_distraction = true
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

	# 3. Enable raycast for placement
	ray_cast.enabled = true
	# Configure ray_cast (adjust collision masks to detect walls/ground)
	# ray_cast.collision_mask = YOUR_WALL_AND_GROUND_LAYERS # Set this in the Inspector or code

func update_placement_preview():
	if not is_instance_valid(preview_dummy): return

# The preview dummy is always centered relative to the placement camera
	# Set its position to the camera's global position.
	preview_dummy.global_position = placement_camera.global_position

	# --- RayCast2D setup ---
	# Raycast origin is the camera's center
	ray_cast.global_position = placement_camera.global_position

	# Raycast target is a short distance downwards (or in the camera's default forward direction if your game has a concept of 'forward')
	# Adjust this Vector2(0, 50) based on how far down you expect the ground to be from the camera's center.
	# It should be long enough to hit the ground but not so long it passes through objects you want to detect.
	ray_cast.target_position = Vector2(0, 0) # Example: 50 pixels directly downwards from camera center

	ray_cast.force_raycast_update() # Ensure raycast is updated immediately

	var can_place = false
	var hit_point = placement_camera.global_position # Default to camera center if no collision

	if ray_cast.is_colliding():
		hit_point = ray_cast.get_collision_point()
		var collider = ray_cast.get_collider()

		# Check if hitting a "wall" or valid ground (using collision layers/groups)
		# Assuming Layer 2 is "Walls" and Layer 3 is "Ground"
		var is_valid_surface = false
		if collider:
			# Check if it's explicitly part of the ground layer (or not a wall layer)
			if collider.get_collision_layer_value(3): # Assuming layer 3 is "Ground"
				is_valid_surface = true
			elif collider.is_in_group("Ground"):
				is_valid_surface = true
			# Explicitly check if it's a wall and invalidate
			if collider.get_collision_layer_value(2) or collider.is_in_group("Walls"): # Assuming layer 2 is "Walls"
				is_valid_surface = false

		# Check if within placement range from the player's actual position
		var player_global_pos = global_position # Your player's actual global position
		var distance_to_player = player_global_pos.distance_to(hit_point)
		var is_in_range = distance_to_player <= placement_range

		can_place = is_in_range and is_valid_surface

	# Set preview dummy position to the hit point, or camera center if no collision
	# This places the dummy *on* the detected surface
	preview_dummy.global_position = hit_point

	# Update preview material based on placement validity
	if can_place:
		if preview_dummy.has_method("set_valid_placement_material"):
			preview_dummy.set_valid_placement_material()
	else:
		if preview_dummy.has_method("set_invalid_placement_material"):
			preview_dummy.set_invalid_placement_material()

# handle_placement_camera_movement(delta) remains the same as it moves the camera (and thus the dummy preview)

func handle_placement_camera_movement(delta):
	if not is_instance_valid(placement_camera): return

	var camera_move_speed = 200.0 # Adjust pixels per second
	var move_direction = Vector2.ZERO

	# WASD movement for camera
	if Input.is_action_pressed("up"): move_direction.y -= 1
	if Input.is_action_pressed("down"): move_direction.y += 1
	if Input.is_action_pressed("left"): move_direction.x -= 1
	if Input.is_action_pressed("right"): move_direction.x += 1

	placement_camera.global_position += move_direction.normalized() * camera_move_speed * delta

func confirm_placement():
	if is_instance_valid(preview_dummy) and ray_cast.is_colliding():
		var hit_point = ray_cast.get_collision_point()
		var player_global_pos = global_position
		var distance_to_player = player_global_pos.distance_to(hit_point)

		# Re-check placement validity before confirming (same logic as in update_placement_preview)
		var collider = ray_cast.get_collider()
		var is_valid_surface = true # Assume valid

		if collider and collider.get_collision_layer_value(2): # Assuming layer 2 is "Walls"
			is_valid_surface = false
		if collider and collider.is_in_group("Walls"):
			is_valid_surface = false

		if distance_to_player <= placement_range and is_valid_surface:
			# Instantiate the actual dummy
			var actual_dummy = distraction_dummy_scene.instantiate()
			get_tree().root.add_child(actual_dummy)
			actual_dummy.global_position = hit_point
			# Reset actual dummy from preview mode
			if actual_dummy.has_method("set_preview_mode"):
				actual_dummy.set_preview_mode(false)
			if actual_dummy.has_method("start_distraction"):
				actual_dummy.start_distraction(distraction_duration)

			# Clean up preview and exit mode
			end_placement_mode()
		else:
			print("Cannot place here (out of range or invalid surface).")
	else:
		print("No valid placement detected.")

func cancel_placement():
	end_placement_mode()

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

	ray_cast.enabled = false # Disable raycast
