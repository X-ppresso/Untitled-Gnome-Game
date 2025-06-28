extends CanvasLayer

@onready var transition = $Transition
var menu = preload("res://Scenes/Menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func pause():
	self.show()
	get_tree().paused = true

func _on_continue_pressed() -> void:
	self.hide()
	get_tree().paused = false
	
func _on_restart_level_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_back_to_menu_pressed() -> void:
	get_tree().paused = false
	$Transition.play("fade_out")
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
