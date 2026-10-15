@icon("res://addons/health-system/icons/spawn_scene_action.svg")
class_name SpawnSceneAction
extends HealthAction
## Instanziert eine Szene als Geschwister des Actors, z. B. Loot beim Tod.

@export var scene: PackedScene
@export var spawn_count := 1


func _init() -> void:
	trigger = Trigger.ON_DEATH


func execute(health: HealthComponent, _context: Dictionary) -> void:
	if scene == null:
		push_warning("SpawnSceneAction: keine Szene gesetzt, es wird nichts gespawnt.")
		return

	var actor := health.get_parent()

	if actor == null:
		return

	var parent := actor.get_parent()

	if parent == null:
		return

	var spawn_position: Variant = null

	if actor is Node2D:
		spawn_position = actor.global_position
	elif actor is Node3D:
		spawn_position = actor.global_position

	_spawn.call_deferred(parent, spawn_position)


func _spawn(parent: Node, spawn_position: Variant) -> void:
	if not is_instance_valid(parent):
		return

	for _index in spawn_count:
		var instance := scene.instantiate()
		parent.add_child(instance)
		_place(instance, spawn_position)


func _place(instance: Node, spawn_position: Variant) -> void:
	if spawn_position is Vector2 and instance is Node2D:
		instance.global_position = spawn_position
	elif spawn_position is Vector3 and instance is Node3D:
		instance.global_position = spawn_position
