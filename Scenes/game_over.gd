extends CanvasLayer

func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	pass # Replace with function body.
	$".".get_tree().reload_current_scene()

func game_over():
	get_tree().paused = true
	self.show()
