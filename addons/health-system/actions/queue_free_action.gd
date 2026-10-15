@icon("res://addons/health-system/icons/queue_free_action.svg")
class_name QueueFreeAction
extends HealthAction
## Löscht den Parent der HealthComponent (den Actor). Optional mit Verzögerung

@export var delay: float = 0.0


func _init() -> void:
	trigger = Trigger.ON_DEATH


func execute(health: HealthComponent, _context: Dictionary) -> void:
	var actor := health.get_parent()

	if actor == null:
		return

	if delay <= 0.0:
		actor.queue_free()
		return

	health.get_tree().create_timer(delay).timeout.connect(
		func() -> void:
			if is_instance_valid(actor):
				actor.queue_free()
	)
