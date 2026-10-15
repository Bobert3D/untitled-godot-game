class_name DamageResult
extends RefCounted
## Beschreibt das tatsächliche Ergebnis eines Schadens-Events.

var final_amount: float = 0.0:
	set(value):
		final_amount = value

		if final_amount == 0:
			was_blocked = true

var blocked_amount: float = 0.0
var overkill: float = 0.0  # Schaden über 0 HP hinaus
var was_lethal: bool = false
var was_blocked: bool = false
