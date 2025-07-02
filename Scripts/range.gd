extends Area2D

@export var cutscene: AnimatedSprite2D
var randomize : float

func _on_body_entered(body: Node2D) -> void:
	get_tree().paused = true
	cutscene.visible = true
	var randomize = randf()
	if randomize < 0.7:
		cutscene.play("default")
	else:
		cutscene.play("rare")

func _on_game_over_animation_finished() -> void:
	get_tree().paused = false
	$"../../Game_Over".game_over()
