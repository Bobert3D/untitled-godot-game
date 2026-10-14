extends CharacterBody2D

var run_speed = 350
var jump_speed = -1000
var gravity = 2500

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	if is_on_floor() and jump:
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
	if left:
		velocity.x -= run_speed

func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	move_and_slide()

func _physics_process_pos(delta):
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		var collision_point = collision_info.get_position()
