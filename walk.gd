extends CharacterBody2D

const WALK_SPEED := 40.0
const FLY_SPEED := 110.0
const LEFT_LIMIT := 20.0
const RIGHT_LIMIT := 300.0
const HOVER_RADIUS := 24.0

enum State { WALK, LOOK, STAND, TALK, FLY_IN, FLY_AWAY }

var direction := 1
var state := State.WALK
var state_time := 0.0
var blink_timer := 3.0
var blinking := false
var talk_timer := 4.0
var ground_y := 0.0
var target_x := 160.0
var fly_vel := Vector2.ZERO
var was_pressed := false

@onready var sprite: AnimatedSprite2D = $duck

func _ready() -> void:
	ground_y = position.y
	_set_state(State.FLY_IN)

func _physics_process(delta: float) -> void:
	var mouse := get_global_mouse_position()
	var near := mouse.distance_to(global_position) < HOVER_RADIUS
	var pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var clicked := pressed and not was_pressed
	was_pressed = pressed
	state_time += delta

	if state == State.FLY_IN:
		var target := Vector2(target_x, ground_y)
		sprite.flip_h = target.x > position.x
		position = position.move_toward(target, FLY_SPEED * delta)
		if position.is_equal_approx(target):
			_set_state(State.WALK)
		return

	if state == State.FLY_AWAY:
		position += fly_vel * delta
		if state_time > 1.5:
			visible = false
		if state_time > 3.0:
			_set_state(State.FLY_IN)
		return

	if near and clicked:
		var away := signf(global_position.x - mouse.x)
		if away == 0.0:
			away = 1.0
		fly_vel = Vector2(away * 0.6, -1.0).normalized() * FLY_SPEED * 1.5
		_set_state(State.FLY_AWAY)
		return

	if state == State.WALK:
		if near:
			_set_state(State.LOOK)
		else:
			_walk(delta)
	elif state == State.LOOK:
		sprite.flip_h = mouse.x > global_position.x
		if state_time > 0.6:
			_set_state(State.STAND)
	elif state == State.STAND:
		sprite.flip_h = mouse.x > global_position.x
		if not near:
			_set_state(State.WALK)
		else:
			_handle_blink(delta)
			talk_timer -= delta
			if talk_timer <= 0.0:
				_set_state(State.TALK)
	elif state == State.TALK:
		sprite.flip_h = mouse.x > global_position.x
		if not near:
			_set_state(State.WALK)
		elif state_time > 1.0:
			_set_state(State.STAND)

func _handle_blink(delta: float) -> void:
	blink_timer -= delta
	if blinking:
		if blink_timer <= 0.0:
			blinking = false
			sprite.play("stand")
			blink_timer = randf_range(2.0, 5.0)
	elif blink_timer <= 0.0:
		blinking = true
		sprite.play("blink")
		blink_timer = 0.15

func _walk(delta: float) -> void:
	position.x += WALK_SPEED * direction * delta

	if position.x >= RIGHT_LIMIT:
		position.x = RIGHT_LIMIT
		direction = -1
	elif position.x <= LEFT_LIMIT:
		position.x = LEFT_LIMIT
		direction = 1

	sprite.flip_h = direction > 0

func _set_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	blinking = false
	if state == State.WALK:
		sprite.play("walk")
	elif state == State.LOOK:
		sprite.play("look-back")
	elif state == State.STAND:
		talk_timer = randf_range(3.0, 6.0)
		sprite.play("stand")
	elif state == State.TALK:
		sprite.play("talk")
	elif state == State.FLY_IN:
		visible = true
		position = Vector2(-30.0, ground_y - 120.0)
		target_x = randf_range(LEFT_LIMIT + 40.0, RIGHT_LIMIT - 40.0)
		sprite.play("fly")
	elif state == State.FLY_AWAY:
		sprite.flip_h = fly_vel.x > 0
		sprite.play("fly")
