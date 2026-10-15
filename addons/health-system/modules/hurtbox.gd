class_name Hurtbox
extends RefCounted
## Geteilte Logik von Hurtbox2D und Hurtbox3D.

const META_DAMAGE := &"damage"
const META_DAMAGE_TYPE := &"damage_type"


static func resolve_health(hurtbox: Node, cached: HealthComponent) -> HealthComponent:
	if is_instance_valid(cached):
		return cached

	return HealthComponent.find(hurtbox.get_parent())


static func receive_damage(
	health: HealthComponent, amount: float, source: Node, type: StringName
) -> DamageResult:
	if health == null:
		push_warning("Hurtbox: keine HealthComponent gefunden")
		return null

	return health.damage(amount, source, type)


static func receive_from_meta(health: HealthComponent, node: Node) -> void:
	if not node.has_meta(META_DAMAGE):
		return

	var type: StringName = node.get_meta(META_DAMAGE_TYPE, &"generic")
	receive_damage(health, node.get_meta(META_DAMAGE), node, type)
