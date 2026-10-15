@icon("res://addons/health-system/icons/regen_module.svg")
class_name RegenModule
extends Node
## Regeneriert HP über Zeit. Als Sibling der HealthComponent hängen.

@export var regen_per_second: float = 5.0
@export var delay_after_damage: float = 0.0
@export var tick_interval: float = 0.5
@export var health_component: HealthComponent

var _time_since_damage: float = 0.0
var _time_since_tick: float = 0.0


func _ready() -> void:
	if not health_component:
		health_component = HealthComponent.find(get_parent())

	if not health_component:
		push_error("RegenModule: keine HealthComponent gefunden")
		set_physics_process(false)
		return

	health_component.damaged.connect(_reset_time_since_damage)


func _physics_process(delta: float) -> void:
	if not health_component or not health_component.is_alive:
		return

	if health_component.current_health >= health_component.max_health:
		return

	if _time_since_damage <= delay_after_damage:
		_time_since_damage += delta
		return

	_time_since_tick += delta

	if _time_since_tick < tick_interval:
		return

	_time_since_tick -= tick_interval
	health_component.heal(regen_per_second * tick_interval, self, &"regen")


func _reset_time_since_damage(_info: DamageInfo, _result: DamageResult) -> void:
	_time_since_damage = 0.0
