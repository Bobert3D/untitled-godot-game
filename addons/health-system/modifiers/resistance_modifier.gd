@icon("res://addons/health-system/icons/resistance_modifier.svg")
class_name ResistanceModifier
extends HealthModifier

@export var resistances: Dictionary = {}


func modify_damage(info: DamageInfo, _health: HealthComponent) -> void:
	if resistances.has(info.damage_type):
		info.amount *= resistances[info.damage_type]
