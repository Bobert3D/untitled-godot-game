@icon("res://addons/health-system/icons/hurtbox_3d.svg")
class_name Hurtbox3D
extends Area3D
## Empfängt Schaden für den Actor. Angreifer rufen receive_damage() auf oder
## setzen die Metadaten "damage" und optional "damage_type" auf ihrer Area
## bzw. ihrem Body.

@export var health_component: HealthComponent


func _ready() -> void:
	area_entered.connect(_on_entered)
	body_entered.connect(_on_entered)


func receive_damage(
	amount: float, source: Node = null, type: StringName = &"generic"
) -> DamageResult:
	return Hurtbox.receive_damage(_resolve_health(), amount, source, type)


func _resolve_health() -> HealthComponent:
	health_component = Hurtbox.resolve_health(self, health_component)
	return health_component


func _on_entered(node: Node) -> void:
	Hurtbox.receive_from_meta(_resolve_health(), node)
