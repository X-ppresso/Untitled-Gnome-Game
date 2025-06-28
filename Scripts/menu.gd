extends Control 

@onready var transition = $Transition
var is_playing = false

func _ready() -> void:
	transition.play("fade_in")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	is_playing = true
	transition.play("fade_out")

func _on_transition_animation_finished(anim_name: StringName) -> void:
	if is_playing == true:
		get_tree().change_scene_to_file("res://Scenes/Game testing.tscn")
		is_playing = false
