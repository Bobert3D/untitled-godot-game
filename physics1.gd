extends CharacterBody2D

var run_speed = 150
var jump_speed = -400
var gravity = 980

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed("ui_right")
	var left = Input.is_action_pressed("ui_left")
	var jump = Input.is_action_just_pressed("ui_accept")

	if is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
	if left:
		velocity.x -= run_speed

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	get_input()
	move_and_slide()
