class_name HealInfo
extends RefCounted
## Transportier alle Daten eines Heal-Events

var amount: float = 0.0
var source: Node = null
var heal_type: StringName = &"generic"
var metadata: Dictionary = {}


func _init(p_amount: float = 0.0, p_source: Node = null, p_type: StringName = &"generic") -> void:
	amount = p_amount
	source = p_source
	heal_type = p_type
