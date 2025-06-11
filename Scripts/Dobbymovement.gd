extends CharacterBody2D

# Movement speed of the character in pixels per second.
@export var speed = 200

# multiplier speed klo lari
@export var run_speed_multiplier = 1.75

# How quickly the character speeds up. Higher values are more responsive.
@export var acceleration = 10

# How quickly the character slows down. Higher values mean less sliding.
@export var friction = 10

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
	
