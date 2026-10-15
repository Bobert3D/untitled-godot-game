@icon("res://addons/health-system/icons/health_component.svg")
class_name HealthComponent
extends Node
## Verwaltet Lebenspunkte eines Actors.

signal tag_added(tag: StringName)
signal tag_removed(tag: StringName)
signal modifier_added(modifier: HealthModifier)
signal modifier_removed(modifier: HealthModifier)
signal action_added(action: HealthAction)
signal action_removed(action: HealthAction)
signal threshold_crossed(threshold: float, going_down: bool)
signal health_changed(old_value: float, new_value: float)
signal damaged(info: DamageInfo, result: DamageResult)
signal healed(info: HealInfo, result: DamageResult)
signal died(info: DamageInfo)
signal revived

@export var health_profile: HealthProfile
@export var max_health: float = 100.0

var current_health: float:
	set(value):
		var old_health = current_health
		current_health = clampf(value, 0.0, max_health)

		if current_health <= 0.0:
			is_alive = false

		if old_health != current_health:
			health_changed.emit(old_health, current_health)
			_check_thresholds(old_health, current_health)

var is_alive: bool = true

var _tags: Dictionary[StringName, int] = {}
var _modifiers: Array[HealthModifier] = []
var _modifier_timers: Dictionary[HealthModifier, SceneTreeTimer] = {}

var _actions: Array[HealthAction] = []


func _ready() -> void:
	if health_profile:
		max_health = health_profile.max_health
		current_health = max_health / 100 * health_profile.start_health_percent

		for modifier in health_profile.default_modifiers:
			if modifier:
				_modifiers.append(modifier.duplicate(true))

		_sort_modifiers()

		for actions in health_profile.actions:
			if actions:
				_actions.append(actions.duplicate(true))

		return

	current_health = max_health


func damage(amount: float, source: Node = null, type: StringName = &"generic") -> DamageResult:
	return apply_damage(DamageInfo.new(amount, source, type))


func heal(amount: float, source: Node = null, type: StringName = &"generic") -> DamageResult:
	return apply_heal(HealInfo.new(amount, source, type))


func apply_damage(info: DamageInfo) -> DamageResult:
	var result := DamageResult.new()

	if not is_alive:
		result.was_blocked = true
		return result

	var incoming := info.amount

	for modifier in _modifiers:
		modifier.modify_damage(info, self)

	info.amount = maxf(info.amount, 0.0)

	result.final_amount = info.amount
	result.blocked_amount = maxf(incoming - info.amount, 0.0)
	result.overkill = maxf(info.amount - current_health, 0.0)

	current_health -= info.amount

	damaged.emit(info, result)
	_run_actions(HealthAction.Trigger.ON_DAMAGED, {"info": info, "result": result})

	if current_health <= 0.0:
		result.was_lethal = true
		died.emit(info)
		_run_actions(HealthAction.Trigger.ON_DEATH, {"info": info})

	return result


func apply_heal(info: HealInfo) -> DamageResult:
	var result := DamageResult.new()

	if not is_alive:
		result.was_blocked = true
		return result

	var incoming := info.amount

	for modifier in _modifiers:
		modifier.modify_heal(info, self)

	info.amount = maxf(info.amount, 0.0)

	result.final_amount = info.amount
	result.blocked_amount = maxf(incoming - info.amount, 0.0)
	result.overkill = maxf(current_health + info.amount - max_health, 0.0)

	current_health += info.amount

	healed.emit(info, result)
	_run_actions(HealthAction.Trigger.ON_HEALED, {"info": info, "result": result})

	return result


func kill() -> void:
	if not is_alive:
		return

	current_health = 0.0
	var info := DamageInfo.new()
	died.emit(info)
	_run_actions(HealthAction.Trigger.ON_DEATH, {"info": info})


func revive(health_percent := 100.0) -> void:
	is_alive = true
	current_health = max_health / 100 * health_percent
	revived.emit()
	_run_actions(HealthAction.Trigger.ON_REVIVE, {})


func get_health_percent() -> float:
	return 100 / max_health * current_health


func _check_thresholds(old_health: float, new_health: float) -> void:
	if not health_profile or not is_node_ready():
		return

	var old_percent := 100 / max_health * old_health
	var new_percent := 100 / max_health * new_health

	for threshold in health_profile.thresholds:
		if old_percent > threshold and new_percent <= threshold:
			threshold_crossed.emit(threshold, true)
			_run_actions(
				HealthAction.Trigger.ON_THRESHOLD, {"threshold": threshold, "going_down": true}
			)
		elif old_percent <= threshold and new_percent > threshold:
			threshold_crossed.emit(threshold, false)
			_run_actions(
				HealthAction.Trigger.ON_THRESHOLD, {"threshold": threshold, "going_down": false}
			)


func add_tag(tag: StringName) -> void:
	_tags[tag] = _tags.get(tag, 0) + 1

	if _tags[tag] == 1:
		tag_added.emit(tag)


func remove_tag(tag: StringName) -> void:
	if not _tags.has(tag):
		return

	_tags[tag] -= 1

	if _tags[tag] <= 0:
		_tags.erase(tag)
		tag_removed.emit(tag)


func has_tag(tag: StringName) -> bool:
	return _tags.has(tag)


func get_tags() -> Array[StringName]:
	var tags: Array[StringName] = []
	tags.assign(_tags.keys())
	return tags


func add_modifier(modifier: HealthModifier, duration: float = 0.0) -> void:
	if modifier == null or _modifiers.has(modifier):
		return

	_modifiers.append(modifier)
	_sort_modifiers()

	if duration > 0.0:
		var timer := get_tree().create_timer(duration)
		_modifier_timers[modifier] = timer
		timer.timeout.connect(_on_modifier_expired.bind(modifier, timer))

	modifier_added.emit(modifier)


func remove_modifier(modifier: HealthModifier) -> void:
	if not _modifiers.has(modifier):
		return

	_modifiers.erase(modifier)
	_modifier_timers.erase(modifier)
	modifier_removed.emit(modifier)


func _on_modifier_expired(modifier: HealthModifier, timer: SceneTreeTimer) -> void:
	if _modifier_timers.get(modifier) != timer:
		return

	remove_modifier(modifier)


func get_modifiers() -> Array[HealthModifier]:
	return _modifiers.duplicate()


func add_action(action: HealthAction) -> void:
	if action == null or _actions.has(action):
		return

	_actions.append(action)
	action_added.emit(action)


func remove_action(action: HealthAction) -> void:
	if not _actions.has(action):
		return

	_actions.erase(action)
	action_removed.emit(action)


func get_action() -> void:
	return _actions.duplicate()


func _sort_modifiers() -> void:
	_modifiers.sort_custom(
		func(a: HealthModifier, b: HealthModifier): return a.priority < b.priority
	)


func _run_actions(trigger: HealthAction.Trigger, context: Dictionary) -> void:
	if _actions.is_empty():
		return

	for action in _actions.duplicate():
		if action.trigger == trigger:
			action.execute(self, context)


static func find(node: Node) -> HealthComponent:
	if node == null:
		return null

	for child in node.get_children():
		if child is HealthComponent:
			return child

	return null
