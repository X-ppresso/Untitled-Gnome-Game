# DistractionDummy.gd (attached to the root Area2D of DistractionDummy.tscn)

extends Area2D

@onready var life_timer: Timer = $LifeTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Adjust path to your Sprite2D node

@export var default_modulate: Color = Color(1, 1, 1, 1) # Opaque white
@export var preview_valid_modulate: Color = Color(0.5, 1, 0.5, 0.5) # Semi-transparent green
@export var preview_invalid_modulate: Color = Color(1, 0.5, 0.5, 0.5) # Semi-transparent red

var is_preview: bool = false
var distraction_duration: float = 0.0

var overlapping_obstacles: int = 0 # Counter for overlapping bodies/areas


func _ready():
	# Connect the timer's timeout signal
	life_timer.timeout.connect(on_life_timer_timeout)
# Connect signals for overlapping bodies/areas (if you haven't already)
	body_entered.connect(_on_body_entered_obstacle)
	body_exited.connect(_on_body_exited_obstacle)
	area_entered.connect(_on_area_entered_obstacle) # If obstacles are Area2Ds
	area_exited.connect(_on_area_exited_obstacle)   # If obstacles are Area2Ds

func set_valid_placement_material():
	if sprite and is_preview:
		sprite.modulate = preview_valid_modulate

func set_invalid_placement_material():
	if sprite and is_preview:
		sprite.modulate = preview_invalid_modulate

func set_preview_mode(is_active: bool):
	is_preview = is_active
	
	# When in preview mode, we only want to detect walls/obstacles for placement.
	# We do NOT want it to trigger NPC distraction yet.
	if is_active:
		# Set its collision layer to "PreviewDummy" (e.g., Layer 5)
		# Its mask should detect walls/obstacles (e.g., Layer 2)
		set_collision_layer_value(5, true) # Enable PreviewDummy layer
		set_collision_mask_value(2, true)  # Detect Walls (Layer 2)
		# Disable detection of NPCs (Layer 4) for preview
		set_collision_mask_value(4, false) # Assuming NPCs are Layer 4
		monitorable = true # Should be true for collision detection
		
		# Reset overlap counter when entering preview mode
		overlapping_obstacles = 0 
		
		set_valid_placement_material()
	else:
		# When placed (actual dummy), enable NPC detection and disable obstacle detection for placement
		set_collision_layer_value(5, false) # Disable PreviewDummy layer
		set_collision_mask_value(2, false)  # Stop detecting Walls
		set_collision_layer_value(4, true)  # Enable its own layer for NPCs to detect (e.g., Layer 4, if dummy also uses that layer for itself)
		set_collision_mask_value(4, true)   # Detect NPCs (e.g., Layer 4 for NPCs)
		
		sprite.modulate = default_modulate
		monitorable = true # Should be true for NPC detection
		
		# Clear any existing overlaps
		overlapping_obstacles = 0


# Call these methods when a body/area enters/exits the preview dummy's Area2D
func _on_body_entered_obstacle(body: Node2D):
	if is_preview: # Only count overlaps if in preview mode
		# Check if the entered body is an obstacle (e.g., in "Walls" group or on "Walls" layer)
		if body.is_in_group("Walls") or body.get_collision_layer_value(2): # Assuming Layer 2 is Walls
			overlapping_obstacles += 1
			# print("Preview entered obstacle: ", body.name, " current overlaps: ", overlapping_obstacles)

func _on_body_exited_obstacle(body: Node2D):
	if is_preview:
		if body.is_in_group("Walls") or body.get_collision_layer_value(2):
			overlapping_obstacles -= 1
			# print("Preview exited obstacle: ", body.name, " current overlaps: ", overlapping_obstacles)

func _on_area_entered_obstacle(area: Area2D):
	if is_preview:
		if area.is_in_group("Walls") or area.get_collision_layer_value(2): # If your walls are Area2Ds
			overlapping_obstacles += 1

func _on_area_exited_obstacle(area: Area2D):
	if is_preview:
		if area.is_in_group("Walls") or area.get_collision_layer_value(2):
			overlapping_obstacles -= 1

func is_overlapping_obstacle() -> bool:
	return overlapping_obstacles > 0


func start_distraction(duration: float):
	distraction_duration = duration
	life_timer.wait_time = distraction_duration
	life_timer.start()
	print("Distraction dummy placed at: ", global_position)

func on_life_timer_timeout():
	print("Distraction dummy vanished!")
	queue_free()

func _on_body_entered(body: Node2D): # For actual dummy, NPC detection
	if not is_preview and body.is_in_group("NPC"):
		body.distract(global_position, self)

func _on_body_exited(body: Node2D): # For actual dummy, NPC detection
	if not is_preview and body.is_in_group("NPC"):
		body.undistract()
