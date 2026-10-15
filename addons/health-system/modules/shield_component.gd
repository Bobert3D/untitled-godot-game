@icon("res://addons/health-system/icons/shield_component.svg")
class_name ShieldComponent
extends Node
## Absorbiert Schaden vor den HP. Als Sibling der HealthComponent
## unter denselben Actor hängen.

signal shield_changed(old_value: float, new_value: float)
signal shield_broken
signal shield_restored

@export var max_shield: float = 50.0
@export var health_component: HealthComponent

var current_shield: float:
	set(value):
		var old_shield := current_shield
		current_shield = clampf(value, 0.0, max_shield)

		if old_shield == current_shield:
			return

		shield_changed.emit(old_shield, current_shield)

		# Beim Aufbau steht der Schild zum ersten Mal auf max - das ist keine
		# Wiederherstellung, also erst ab dann melden.
		if not _started:
			return

		if current_shield == 0.0:
			shield_broken.emit()
		elif current_shield == max_shield:
			shield_restored.emit()

var _shield_absorb_modifier: ShieldAbsorbModifier
var _started := false


## Die Registrierung haengt am Baum-Eintritt, nicht an _ready(): Godot ruft
## _ready() nur einmal je Node, ein umgehaengter Actor haette sonst einen
## stillen, wirkungslosen Schild.
func _enter_tree() -> void:
	if not is_instance_valid(health_component):
		health_component = HealthComponent.find(get_parent())

	if not health_component:
		push_error("ShieldComponent: keine HealthComponent gefunden, der Schild wirkt nicht.")
		return

	if _shield_absorb_modifier == null:
		_shield_absorb_modifier = ShieldAbsorbModifier.new()
		_shield_absorb_modifier.shield = self

	health_component.add_modifier(_shield_absorb_modifier)


func _ready() -> void:
	current_shield = max_shield
	_started = true


func _exit_tree() -> void:
	if _shield_absorb_modifier == null or not is_instance_valid(health_component):
		return

	health_component.remove_modifier(_shield_absorb_modifier)


func restore_shield(amount: float) -> void:
	current_shield += amount


func break_shield() -> void:
	current_shield = 0.0
