extends Node

var max_health: int = 3
var current_health: int = max_health: 
	set(value):
		current_health = max(0, min(value, max_health))  # Ensures health stays within bounds
		on_health_changed.emit(current_health)  # ✅ Always emit when health changes

signal on_health_changed(player_current_health)

func _ready():
	on_health_changed.emit(current_health)  # ✅ Ensure UI updates at the start

func reset_health(): 
	current_health = max_health  # ✅ Reset health on player death
	on_health_changed.emit(current_health)  # ✅ Ensure UI updates
	print("Health reset on player death")

func decrease_health(health_amount: int):
	current_health -= health_amount  # ✅ Signal is emitted via setter
	print("decrease_health called, new health:", current_health)

func increase_health(health_amount: int):
	current_health += health_amount  # ✅ Signal is emitted via setter
	print("increase_health called, new health:", current_health)

func save_health() -> int:
	return current_health

func load_health(saved_health: int):
	current_health = saved_health if saved_health > 0 else max_health
	on_health_changed.emit(current_health)  # ✅ Ensure UI updates after loading
	print("Loaded health:", current_health)
