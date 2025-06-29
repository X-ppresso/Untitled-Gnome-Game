extends CharacterBody2D

@export var path : PathFinding
@export var speed : float

func _physics_process(delta: float) -> void:
	velocity = path.direction * speed
	$AnimatedSprite2D.play("run")
	
	move_and_slide()
