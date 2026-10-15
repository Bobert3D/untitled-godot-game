@icon("res://addons/health-system/icons/damage_cap_modifier.svg")
class_name DamageCapModifier
extends HealthModifier

@export var max_flat: float = 50.0
@export var max_percent_of_max_health: float = 0.0


func _init() -> void:
	priority = 80


func modify_damage(info: DamageInfo, health: HealthComponent) -> void:
	var cap := 0.0

	if max_flat > 0.0:
		cap = max_flat

	if max_percent_of_max_health > 0.0:
		var percent_cap := health.max_health / 100 * max_percent_of_max_health
		if cap <= 0.0:
			cap = percent_cap
		else:
			cap = minf(percent_cap, cap)

	if cap > 0.0:
		info.amount = minf(info.amount, cap)
