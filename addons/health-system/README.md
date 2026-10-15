# Health System

A health and damage system for Godot 4.7. You add a `HealthComponent` to your actor. Everything else is set up as resources in the inspector: armor, resistances, loot drops, invincibility frames.

A goblin with armor, a loot drop and a despawn on death needs no GDScript at all.

`HealthComponent` extends `Node`, not `Node2D` or `Node3D`. The same profiles work in a platformer and in a first-person shooter. Only the two hurtbox wrappers contain 2D or 3D specific code.

## Installation

1. Copy `addons/health-system/` into your project
2. Go to **Project → Project Settings → Plugins** and enable `health-system`

## An enemy in 60 seconds

**Build the scene.** A `CharacterBody2D` as the root, with a `HealthComponent` underneath:

```
Goblin (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── HealthComponent
└── Hurtbox2D
    └── CollisionShape2D
```

The `Hurtbox2D` finds the `HealthComponent` on its own, as long as the two are siblings.

**Create a profile.** Right-click in the FileSystem, pick **New Resource**, choose `HealthProfile` and save it as `goblin.tres`:

| Field | Value |
|---|---|
| `max_health` | `30` |
| `default_modifiers` | one `ArmorModifier` with `armor = 3` |
| `actions` | one `SpawnSceneAction` (`scene = coin.tscn`, `spawn_count = 2`) and one `QueueFreeAction` |

**Assign it.** Drag `goblin.tres` into the `health_profile` field of the `HealthComponent`.

That is the whole setup. The goblin has 30 HP, takes 3 less damage per hit, drops two coins when it dies and removes itself from the tree. Every other enemy is another `.tres` file, not another script.

To deal damage from game code:

```gdscript
var health := HealthComponent.find(goblin)
var result := health.damage(10.0, self, &"fire")

print(result.final_amount)  # 7.0, the armor took 3 off
```

You can also do it without any code, through the hurtbox. See [Modules](#modules).

---

## Concepts

### HealthComponent

This is the only node you always need. It stores the health value, runs the modifier pipeline and sends the signals.

```gdscript
@export var health_profile: HealthProfile
@export var max_health: float = 100.0

var current_health: float
var is_alive: bool
```

The methods you will use most:

```gdscript
health.damage(25.0, attacker, &"fire")   # -> DamageResult
health.heal(10.0, potion, &"potion")     # -> DamageResult
health.kill()
health.revive(50.0)                      # percent of max_health
health.get_health_percent()              # 0.0 .. 100.0
```

`damage()` and `heal()` are shortcuts. If you need to pass more data along, like a hit position for particles or your own metadata, build the info object yourself:

```gdscript
var info := DamageInfo.new(25.0, attacker, &"fire")
info.position = hit_position
info.metadata["critical"] = true

var result := health.apply_damage(info)
```

Both calls return a `DamageResult`:

| Field | Meaning |
|---|---|
| `final_amount` | what was actually subtracted after all modifiers |
| `blocked_amount` | how much less that is than the incoming value, so armor, resistance and shield together |
| `overkill` | damage dealt past 0 HP |
| `was_lethal` | this hit killed |
| `was_blocked` | nothing got through |

`HealthComponent.find(node)` searches a node's children for the component. That is the usual way to get from a bullet to its target.

### Profiles

A `HealthProfile` is a `.tres` file that describes one type of actor. It has five fields:

```gdscript
@export var max_health: float = 100.0
@export var start_health_percent: float = 100.0
@export var thresholds: Array[float] = []
@export var default_modifiers: Array[HealthModifier] = []
@export var actions: Array[HealthAction] = []
```

`thresholds` are percentage marks. When health crosses one of them in either direction, the component emits `threshold_crossed`. So a boss with `[25.0]` tells you itself when its enrage phase starts.

### Modifiers

A `HealthModifier` sits between the incoming damage and the health value and can change the number. All modifiers on an actor run one after another, sorted by `priority`, lowest first.

These come with the addon:

| Class | Priority | Effect |
|---|---|---|
| `ArmorModifier` | 20 | flat reduction, never below `min_damage` |
| `ResistanceModifier` | 50 | multiplier per damage type, `0.0` for immunity, `2.0` for a weakness |
| `DamageCapModifier` | 80 | limit per hit, either flat or as a percentage of max health |
| `ShieldAbsorbModifier` | 85 | takes from the shield pool, managed by `ShieldComponent` |
| `BlockAllDamageModifier` | 90 | sets the hit to 0 |

You can attach one at runtime, with or without a duration:

```gdscript
var shout := ArmorModifier.new()
shout.armor = 10.0

health.add_modifier(shout, 5.0)   # armor buff for five seconds
health.remove_modifier(shout)     # or take it off yourself
```

Without a duration the modifier stays until someone removes it. Adding the same instance twice does nothing. Two separate instances do stack.

### The priority convention

The numbers are a convention. Nothing in the code enforces them. They exist so that modifiers from different sources end up in a sensible order:

| Range | For | Reason |
|---|---|---|
| 20 | flat reductions | they should run before anything multiplies |
| 50 | multipliers | resistances, weaknesses, vulnerability windows |
| 80 | limits | they work on the finished number |
| 85 | shield | absorbs what would otherwise hit the health |
| 90 | hard blocks | runs last |

The order changes the result. `(40 - 5) * 0.5 = 17.5`, but `40 * 0.5 - 5 = 15`. Which number the player sees depends on the priority.

### Actions

Modifiers change numbers. Actions react to events. You put them in the profile or add them at runtime, and they replace the signal wiring you would otherwise write in an enemy script.

There are five triggers, shown as a dropdown in the inspector:

| Trigger | Context |
|---|---|
| `ON_DAMAGED` | `{"info": DamageInfo, "result": DamageResult}` |
| `ON_HEALED` | `{"info": HealInfo, "result": DamageResult}` |
| `ON_DEATH` | `{"info": DamageInfo}` |
| `ON_THRESHOLD` | `{"threshold": float, "going_down": bool}` |
| `ON_REVIVE` | `{}` |

These come with the addon:

- **`QueueFreeAction`** removes the actor on death. It has an optional `delay` so a death animation can finish first.
- **`SpawnSceneAction`** creates `scene` as a sibling of the actor, `spawn_count` times. If the actor is a Node2D or Node3D, matching instances get its position.
- **`ApplyInvincibilityAction`** gives i-frames after a hit, using the tag `invincible` and a block that runs out on its own.

### Tags

Tags are how the health system talks to the rest of your game. They are counted, so if two sources set `stunned`, only removing the second one emits `tag_removed`.

```gdscript
health.add_tag(&"burning")
health.has_tag(&"burning")     # true
health.get_tags()              # Array[StringName]
health.remove_tag(&"burning")
```

That means the blinking during i-frames needs to know nothing about modifiers:

```gdscript
func _ready() -> void:
	health.tag_added.connect(func(tag): if tag == &"invincible": _start_blink())
	health.tag_removed.connect(func(tag): if tag == &"invincible": _stop_blink())
```

### Modules

These nodes are optional. Whatever you do not put in the tree does not exist at runtime.

**`ShieldComponent`** is a separate pool that soaks up damage before it reaches the health value. Put it next to the `HealthComponent` as a sibling. It hooks into the pipeline through a modifier at priority 85, so the core knows nothing about it.

```gdscript
signal shield_changed(old_value: float, new_value: float)
signal shield_broken
signal shield_restored

@export var max_shield: float = 50.0

shield.restore_shield(20.0)
shield.break_shield()
```

**`RegenModule`** heals over time:

```gdscript
@export var regen_per_second: float = 5.0
@export var delay_after_damage: float = 0.0
@export var tick_interval: float = 0.5
```

It heals through the normal `heal()` API, so regeneration goes through the modifier pipeline like everything else. A modifier that halves healing also halves regeneration. The heal type is `&"regen"` if you want to treat it separately.

**`Hurtbox2D`** and **`Hurtbox3D`** turn area collisions into damage. The attacking side stays your code. All that is standardised is how a hit arrives.

You can do it without writing anything. Give the lava node an entry under **Node → Metadata** called `damage` with the value `100`, and if you want, `damage_type` with `"fire"`. When the player walks in, the hurtbox reads the metadata and calls `damage()`.

Or from code:

```gdscript
hurtbox.receive_damage(100.0, self, &"fire")
```

`receive_damage` returns the `DamageResult`. If it cannot find a `HealthComponent`, it returns `null` and prints a warning.

---

## Writing your own modifier

Anything that changes a damage or heal number is a modifier. Four steps.

**1. Create the file** and extend `HealthModifier`.

```gdscript
class_name GlassCannonModifier
extends HealthModifier
## Below a health threshold, every hit lands harder.
```

**2. Add the settings as exports.** Whatever you put here is what a designer fills in inside the `.tres` file.

```gdscript
@export var threshold_percent: float = 30.0
@export var multiplier: float = 2.0
```

**3. Set the priority.** Multipliers belong around 50, see the convention above.

```gdscript
func _init() -> void:
	priority = 50
```

**4. Override `modify_damage()`.** The second parameter is the `HealthComponent`. That is what it is for, when your modifier needs to know the state of the actor.

```gdscript
func modify_damage(info: DamageInfo, health: HealthComponent) -> void:
	if health.get_health_percent() > threshold_percent:
		return

	info.amount *= multiplier
```

For healing there is `modify_heal(info: HealInfo, health: HealthComponent)`. Both are optional, so override only what you need.

When you are done, list it under `default_modifiers` in a `.tres` file, or attach it at runtime.

## Writing your own action

Anything that reacts to an event instead of changing a number.

**1. Create the file** and extend `HealthAction`.

```gdscript
class_name GrantExperienceAction
extends HealthAction
## Awards experience to whoever landed the killing blow.
```

**2. Add the settings as exports.**

```gdscript
@export var experience: int = 10
```

**3. Set a default trigger.** It stays editable in the inspector.
```gdscript
func _init() -> void:
	trigger = Trigger.ON_DEATH
```

**4. Override `execute()`.** The context is a `Dictionary`. Which keys it holds depends on the trigger, see the table above.

```gdscript
func execute(_health: HealthComponent, context: Dictionary) -> void:
	var info: DamageInfo = context["info"]

	if info.source and info.source.has_method("grant_experience"):
		info.source.grant_experience(experience)
```

When you are done, list it under `actions` in a `.tres` file, or call `health.add_action(action)` at runtime.

---

## Signals

All of these are on the `HealthComponent`:

| Signal | Arguments | When |
|---|---|---|
| `health_changed` | `old_value: float`, `new_value: float` | on any change to the health value, including at startup |
| `damaged` | `info: DamageInfo`, `result: DamageResult` | after every hit, even one that was blocked completely |
| `healed` | `info: HealInfo`, `result: DamageResult` | after every heal |
| `died` | `info: DamageInfo` | once per death |
| `revived` | none | after `revive()` |
| `threshold_crossed` | `threshold: float`, `going_down: bool` | when health crosses a profile mark in either direction |
| `tag_added` | `tag: StringName` | when a tag is set for the first time |
| `tag_removed` | `tag: StringName` | when the last source gives it up |
| `modifier_added` | `modifier: HealthModifier` | on `add_modifier()` |
| `modifier_removed` | `modifier: HealthModifier` | on `remove_modifier()` and when a duration runs out |
| `action_added` | `action: HealthAction` | on `add_action()` |
| `action_removed` | `action: HealthAction` | on `remove_action()` |

On the `ShieldComponent`:

| Signal | Arguments | When |
|---|---|---|
| `shield_changed` | `old_value: float`, `new_value: float` | on any change, including at startup |
| `shield_broken` | none | when the shield drops to 0 |
| `shield_restored` | none | when it is full again |

## Tests

The suite runs on [gdUnit4](https://github.com/MikeSchulze/gdUnit4) and covers every public method and signal. It is not part of this download. The tests and the command to run them are in the [repository](https://github.com/JohnSoellnerDev/health-system).

## License

MIT, Copyright (c) 2026 John Söllner. The full text is in [LICENSE](LICENSE).

The editor icons in `addons/health-system/icons/` come from the [@icons](https://github.com/Voxybuns/at-icons) set by Valentin Fossati (Voxybuns), which is MIT as well. Its license sits unchanged in the same folder and covers those SVG files. The icons are copied into the addon instead of referenced, so you do not need the icon plugin installed.

---

## How AI was used here

I build this addon to learn Godot and to get better at architecture. So I write the source code by hand. The component layout, the modifier pipeline, the priority model, the action system and the modules are mine, both the design and the typing. An assistant that hands me a finished file would defeat the point.

I did use AI in three places.

**Tests:** The gdUnit4 suites are written by AI, based on the acceptance criteria in my own tickets. The loop was the same every time. I hand over the ticket, I get tests back, I run them, I look at what turned red. It found a good number of real bugs that I would otherwise have run into in the game.

**Comments and documentation:** The doc comments and this README. Writing is not my strong side, and a reference implementation that nobody can follow is not much of a reference.

**Commit messages:** it is just easier and helps others understand my changes :3

**CI/CD.**
