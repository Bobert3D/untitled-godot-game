@icon("res://addons/health-system/icons/block_all_damage_modifier.svg")
class_name BlockAllDamageModifier
extends HealthModifier
## Blockt jeglichen eingehenden Schaden. Für i-Frames als timed Modifier nutzen.


func _init() -> void:
	priority = 90


func modify_damage(info: DamageInfo, _health: HealthComponent) -> void:
	info.amount = 0.0
