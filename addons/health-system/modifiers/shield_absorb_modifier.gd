@icon("res://addons/health-system/icons/shield_absorb_modifier.svg")
class_name ShieldAbsorbModifier
extends HealthModifier
## Zieht eingehenden Schaden vom Schild ab, bevor er die HP erreicht.

var shield: ShieldComponent


func _init() -> void:
	priority = 85


func modify_damage(info: DamageInfo, _health: HealthComponent) -> void:
	if info.amount <= 0.0 or not is_instance_valid(shield):
		return

	var absorbed := minf(info.amount, shield.current_shield)

	if absorbed <= 0.0:
		return

	shield.current_shield -= absorbed
	info.amount -= absorbed
	info.metadata["shield_absorbed"] = absorbed
