@icon("res://addons/health-system/icons/armor_modifier.svg")
class_name ArmorModifier
extends HealthModifier
## Zieht einen flachen Wert von eingehendem Schaden ab. Schaden fällt nie unter min_damage.

@export var armor: float = 5.0
@export var min_damage: float = 1.0


func _init() -> void:
	priority = 20


func modify_damage(info: DamageInfo, _health: HealthComponent) -> void:
	if info.amount <= 0.0:
		return

	info.amount = maxf(info.amount - armor, min_damage)
