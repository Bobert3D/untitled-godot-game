extends Control

@export var rotation_speed = 3.0
@export var max_rotation = 4.0
@export var pulse_speed = 2.0
@export var pulse_amount = 0.05

var time = 0.0
var original_scale = Vector2.ONE
var pivot_set = false

func _process(delta):
	if not pivot_set and size != Vector2.ZERO:
		pivot_offset = size / 2.0
		original_scale = scale
		pivot_set = true
		
	if pivot_set:
		time += delta
		rotation_degrees = sin(time * rotation_speed) * max_rotation
		var scale_factor = 1.0 + (sin(time * pulse_speed) * pulse_amount)
		scale = original_scale * scale_factor
