extends CharacterBody2D

const SPEED = 120.0
var direction = 1 

var step_counter = 0


const MAX_STEPS = 150 

@onready var animated_sprite = $duck

func _physics_process(_delta):

	velocity.x = direction * SPEED
	animated_sprite.play("walk")
	
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	move_and_slide()

	step_counter += 1


	if step_counter >= MAX_STEPS:
		direction = -direction 
		step_counter = 0        
