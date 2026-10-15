@icon("res://addons/health-system/icons/health_action.svg")
@abstract class_name HealthAction
extends Resource
## Basisklasse für Aktionen, die auf Health-Events reagieren.
## Überschreibe execute() und wähle den Trigger im Inspector.

enum Trigger {
	ON_DAMAGED,
	ON_HEALED,
	ON_DEATH,
	ON_REVIVE,
	ON_THRESHOLD,
}

@export var trigger: Trigger = Trigger.ON_DEATH


func execute(_health: HealthComponent, _context: Dictionary) -> void:
	pass
