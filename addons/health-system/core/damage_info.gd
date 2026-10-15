class_name DamageInfo
extends RefCounted
## Transportier alle Daten eines Schadens-Events

var amount: float = 0.0
var source: Node = null
var damage_type: StringName = &"generic"
var position: Vector3 = Vector3.ZERO
var metadata: Dictionary = {}


func _init(p_amount: float = 0.0, p_source: Node = null, p_type: StringName = &"generic") -> void:
	amount = p_amount
	source = p_source
	damage_type = p_type
