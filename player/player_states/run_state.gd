extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D

@export_category("Run state")
@export var speed : int = 700
@export var max_horizontal_speed : int = 300

func on_process(delta : float):
	pass


func on_physics_process(delta : float):
	var direction : float = GameInputEvents.movement_input()

	# Only move if on the ground
	if character_body_2d.is_on_floor():
		if direction:
			character_body_2d.velocity.x += direction * speed
			character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed, max_horizontal_speed)
	else:
		transition.emit("Fall")  # Transition to fall state if no ground

	if direction != 0:
		animated_sprite_2d.flip_h = false if direction > 0 else true

	character_body_2d.move_and_slide()

	# transitioning states
	if direction == 0:
		transition.emit("Idle")
	if GameInputEvents.jump_input():
		transition.emit("Jump")
	if direction != 0 and GameInputEvents.shoot_input():
		transition.emit("ShootRun")


func enter():
	animated_sprite_2d.play("run")


func exit():
	animated_sprite_2d.stop()
