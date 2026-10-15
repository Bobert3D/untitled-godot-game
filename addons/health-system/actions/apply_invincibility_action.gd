@icon("res://addons/health-system/icons/apply_invincibility_action.svg")
class_name ApplyInvincibilityAction
extends HealthAction
## Macht den Actor nach einem Treffer für kurze Zeit unverwundbar (i-Frames).

@export var duration: float = 1.0


func _init() -> void:
	trigger = Trigger.ON_DAMAGED


func execute(health: HealthComponent, context: Dictionary) -> void:
	var result: DamageResult = context.get("result")

	if result and result.was_blocked:
		return
	if health.has_tag(&"invincible"):
		return

	var block := BlockAllDamageModifier.new()
	health.add_tag(&"invincible")
	health.add_modifier(block, duration)

	health.modifier_removed.connect(_on_modifier_removed.bind(health, block))


func _on_modifier_removed(
	removed: HealthModifier, health: HealthComponent, block: HealthModifier
) -> void:
	if removed != block:
		return

	health.remove_tag(&"invincible")
	health.modifier_removed.disconnect(_on_modifier_removed.bind(health, block))
