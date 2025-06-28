extends CharacterBody2D

@export var path : PathFinding
@export var speed : float

func _physics_process(delta: float) -> void:
	velocity = path.direction * speed
	move_and_slide()
