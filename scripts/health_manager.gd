extends Node

var max_health : int = 3
var current_health : int

signal on_health_changed


func _ready():
	current_health = max_health


func reset_health(): 
	# Added: Reset health to max when called
	current_health = max_health
	on_health_changed.emit(current_health)
	print("Health reset on player death")


func decrease_health(health_amount : int):
	current_health -= health_amount
	
	if current_health < 0:
		current_health = 0
	
	print("decrease_health called")
	on_health_changed.emit(current_health)


func increase_health(health_amount : int):
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
	
	print("increase_health called")
	on_health_changed.emit(current_health)


func save_health():
	return current_health


func load_health(saved_health: int):
	if saved_health > 0:
		current_health = saved_health
	else:
		current_health = max_health  # Only reset if it's a new game

	print("Loaded health:", current_health)
	on_health_changed.emit(current_health)
