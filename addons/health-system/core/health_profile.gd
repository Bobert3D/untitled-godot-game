@icon("res://addons/health-system/icons/health_profile.svg")
class_name HealthProfile
extends Resource
## Konfiguration einer HealthComponent.

@export var max_health: float = 100.0

@export_range(0.0, 100.0) var start_health_percent: float = 100.0

@export var thresholds: Array[float] = []

@export var default_modifiers: Array[HealthModifier] = []

@export var actions: Array[HealthAction] = []
