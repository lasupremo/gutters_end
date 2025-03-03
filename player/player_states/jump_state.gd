extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D

@export_category("Jump State")
@export var jump_height : float = -300
@export var jump_horizontal_speed : int = 500
@export var max_jump_horizontal_speed : int = 300
@export var max_jump_count : int = 2  # ✅ Allows proper double jump
@export var jump_gravity : int = 800
@export var coyote_time_duration: float = 0.1  # ✅ Small buffer for coyote jump

var current_jump_count : int = 0
var coyote_jump : bool = false
var coyote_time_left: float = 0.0  # ✅ Coyote time countdown
var just_jumped: bool = false  # ✅ Prevents instant idle transition
var was_on_floor: bool = false  # ✅ Tracks if the player was grounded last frame

func on_physics_process(delta : float):
	# ✅ Apply gravity
	character_body_2d.velocity.y += jump_gravity * delta

	# ✅ Check if the player just landed
	var currently_on_floor = character_body_2d.is_on_floor()

	if currently_on_floor and !was_on_floor:
		#print("Player Just Landed - Reset Jump Count!")  # ✅ Debugging print
		current_jump_count = 0  # ✅ Now fully resets every time the player lands
		coyote_jump = true
		coyote_time_left = coyote_time_duration  # ✅ Start coyote time
		just_jumped = false  # ✅ Prevent instant idle transition

	was_on_floor = currently_on_floor  # ✅ Save the last floor state

	# ✅ Coyote time countdown
	if coyote_jump:
		coyote_time_left -= delta
		if coyote_time_left <= 0:
			coyote_jump = false  # ✅ Expire coyote jump

	# ✅ Jump Logic (Now Allows Proper Double Jump)
	if GameInputEvents.jump_input():
		if (character_body_2d.is_on_floor() or coyote_jump or current_jump_count < max_jump_count - 1):  # ✅ Fix: Ensures only 2 jumps total
			character_body_2d.velocity.y = jump_height
			coyote_jump = false
			current_jump_count += 1
			#print("Jump Count:", current_jump_count)  # ✅ Debugging print
			just_jumped = true

	# ✅ Handle horizontal movement while jumping
	var direction : float = GameInputEvents.movement_input()
	if !character_body_2d.is_on_floor():
		character_body_2d.velocity.x += direction * jump_horizontal_speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)

	character_body_2d.move_and_slide()
	#print("Grounded After Move:", character_body_2d.is_on_floor())  # ✅ Debugging print

	# ✅ State Transitions
	if character_body_2d.is_on_floor() and not just_jumped:
		transition.emit("Idle")

	if GameInputEvents.wall_cling_input() and character_body_2d.is_on_wall():
		transition.emit("ShootWallCling")

func enter():
	#print("Jump State Entered!")
	animated_sprite_2d.play("jump")

	# ✅ Fix: Allow immediate jump if jump was already pressed
	if GameInputEvents.jump_input():
		character_body_2d.velocity.y = jump_height
		just_jumped = true

func exit():
	animated_sprite_2d.stop()
