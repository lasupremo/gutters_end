extends Node

var max_health : int = 3
var current_health : int

signal on_health_changed


func _ready():
	current_health = max_health


func reset_health(): 
	# Added: Reset health to max when called
	current_health = max_health
	on_health_changed.emit(current_health) # Notify UI or other systems


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
