extends CharacterBody2D

@export var path : PathFinding
@export var speed : float
@export var timer_ : Timer
@export var spawn : Marker2D

func _physics_process(delta: float) -> void:
	velocity = path.direction * speed
	move_and_slide()
	
	$AnimatedSprite2D.play("run")


func spawn_to_map():
	self.global_position = spawn.global_position

func _on_timer_timeout() -> void:
	spawn_to_map()
