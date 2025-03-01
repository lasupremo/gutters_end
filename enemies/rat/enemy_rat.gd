extends CharacterBody2D

const GRAVITY = 1000


func _ready():
	pass


func _physics_process(delta : float):
	enemy_gravity(delta)
	
	move_and_slide()


func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta
