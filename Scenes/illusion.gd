# DistractionDummy.gd (attached to the root Area2D of DistractionDummy.tscn)

extends Area2D

@onready var life_timer: Timer = $LifeTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # Adjust path to your Sprite2D node

@export var default_modulate: Color = Color(1, 1, 1, 1) # Opaque white
@export var preview_valid_modulate: Color = Color(0.5, 1, 0.5, 0.5) # Semi-transparent green
@export var preview_invalid_modulate: Color = Color(1, 0.5, 0.5, 0.5) # Semi-transparent red

var is_preview: bool = false
var distraction_duration: float = 0.0

func _ready():
	# Connect the timer's timeout signal
	life_timer.timeout.connect(on_life_timer_timeout)

func set_preview_mode(is_active: bool):
	is_preview = is_active
	# Disable collision monitoring for preview
	monitorable = not is_active # Area2D property
	set_collision_mask_value(1, not is_active) # Assuming layer 1 is for NPC detection
	set_collision_layer_value(1, not is_active) # Assuming layer 1 is for NPC detection

	# Set sprite modulation for preview
	if is_active:
		set_valid_placement_material() # Start as valid or default
	else:
		# Restore normal modulation for actual placed dummy
		sprite.modulate = Color(0,1,0)
		# Re-enable collision layers/masks if needed for actual object
		# set_collision_layer_value(YOUR_LAYER_FOR_NPC_DETECTION, true)
		# set_collision_mask_value(YOUR_MASK_FOR_NPC_DETECTION, true)


func set_valid_placement_material():
	if sprite and is_preview:
		sprite.modulate = preview_valid_modulate

func set_invalid_placement_material():
	if sprite and is_preview:
		sprite.modulate = preview_invalid_modulate

func start_distraction(duration: float):
	distraction_duration = duration
	life_timer.wait_time = distraction_duration
	life_timer.start()
	# Play any animation for the dummy
	# if $AnimationPlayer: $AnimationPlayer.play("distract_idle")

	# (Optional) Emit a signal that NPCs can listen to
	# emit_signal("distraction_placed", global_position)
	print("Distraction dummy placed at: ", global_position)


func on_life_timer_timeout():
	print("Distraction dummy vanished!")
	# Potentially emit a signal for NPCs to stop being distracted
	# emit_signal("distraction_vanished", self)
	queue_free() # Remove the dummy

# Connect this signal in the Node tab of your DistractionDummy (Area2D)
func _on_body_entered(body: Node2D):
	if not is_preview and body.is_in_group("NPC"): # Assuming your NPCs are in group "NPC"
		print("NPC entered distraction area: ", body.name)
		body.distract(global_position, self) # Call a method on the NPC to distract it

# Connect this signal in the Node tab of your DistractionDummy (Area2D)
func _on_body_exited(body: Node2D):
	if not is_preview and body.is_in_group("NPC"):
		print("NPC exited distraction area: ", body.name)
		body.undistract() # Call a method on the NPC to undistract it (if it needs to know when to stop)
