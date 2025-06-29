extends CanvasLayer

@onready var transition = $Transition
var is_exiting = false
var is_restarting = false

func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	is_restarting = true
	transition.play("fade_out")

func _on_exit_pressed() -> void:
	is_exiting = true
	transition.play("fade_out")
	
func _on_transition_animation_finished(anim_name: StringName) -> void:
	get_tree().paused = false
	if is_exiting == true :
		get_tree().change_scene_to_file("res://Scenes/ui/Menu.tscn")
		is_exiting = false
	elif is_restarting == true :
		get_tree().reload_current_scene()
		is_restarting = false
	else:
		pass

func game_over():
	get_tree().paused = true
	self.show()
