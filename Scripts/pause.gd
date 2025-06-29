extends CanvasLayer

@onready var transition = $Transition
var menu = preload("res://Scenes/ui/Menu.tscn")
var is_restarting = false
var is_exiting = false
var is_paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func _on_continue_pressed() -> void:
	self.hide()
	get_tree().paused = false
	
func _on_restart_level_pressed() -> void:
	is_restarting = true
	$Transition.play("fade_out")

func _on_back_to_menu_pressed() -> void:
	is_exiting = true
	$Transition.play("fade_out")

func _on_transition_animation_finished(anim_name: StringName) -> void:
	get_tree().paused = false

	if is_restarting == true:
		get_tree().reload_current_scene()
		is_restarting = false
		
	elif is_exiting == true:
		get_tree().change_scene_to_file("res://Scenes/ui/Menu.tscn")
		is_exiting = false
	else:
		pass

func pause():
	is_paused = true
	self.show()
	get_tree().paused = true
