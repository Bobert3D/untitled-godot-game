@icon("res://addons/health-system/icons/health_modifier.svg")
@abstract class_name HealthModifier
extends Resource
## Basisklasse für alle Modifier.

@export_range(0, 100) var priority: int = 50


func modify_damage(_info: DamageInfo, _health: HealthComponent) -> void:
	pass


func modify_heal(_info: HealInfo, _health: HealthComponent) -> void:
	pass
