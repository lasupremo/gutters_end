extends CharacterBody2D

var enemy_death_effect = preload("res://enemies/enemy_death_effect.tscn")

@export var patrol_points : Node
@export var speed : int = 1500
@export var wait_time : int = 3
@export var health_amount : int = 3
@export var damage_amount : int = 1

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer

const GRAVITY = 1000

enum State { Idle, Walk }
var current_state : State
var direction : Vector2 = Vector2.LEFT
var number_of_points : int
var point_positions : Array[Vector2]
var current_point : Vector2
var current_point_position : int
var can_walk : bool

func _ready():
	# Ensure Hurtbox is active
	$Hurtbox.set_deferred("monitoring", true)
	$Hurtbox.set_deferred("monitorable", true)
	#print("Enemy Hurtbox Active?", $Hurtbox.monitoring, "| Monitorable?", $Hurtbox.monitorable)

	# Modify collision settings so enemy passes through player
	set_collision_layer_value(3, true)  # Keep enemy in Layer 3
	set_collision_mask_value(2, false)  # Disable collision with Player's solid body
	set_collision_mask_value(4, true)   # Allow enemy to detect Player's Hurtbox

	#print("Enemy now passes through Player but still triggers Hurtbox!")

	# Setup patrol points if available
	if patrol_points != null:
		number_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points")

	timer.wait_time = wait_time
	current_state = State.Idle


func _physics_process(delta : float):
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_walk(delta)
	
	move_and_slide()
	
	enemy_animations()


func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta


func enemy_idle(delta : float):
	if !can_walk:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		current_state = State.Idle


func enemy_walk(delta : float):
	if !can_walk:
		return

	var distance_to_target = current_point.x - position.x
	var movement_direction = sign(distance_to_target)

	velocity.x = direction.x * speed * delta

	if abs(distance_to_target) <= abs(velocity.x * delta): # Check if next step will overshoot
		position.x = current_point.x # Correct position
		velocity.x = 0 # stop moving
		current_point_position += 1

		if current_point_position >= number_of_points:
			current_point_position = 0

		current_point = point_positions[current_point_position]

		if current_point.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT

		can_walk = false
		timer.start()
	else:
		current_state = State.Walk

	animated_sprite_2d.flip_h = direction.x > 0


func enemy_animations():
	if current_state == State.Idle && !can_walk:
		animated_sprite_2d.play("idle")
	elif current_state == State.Walk && can_walk:
		animated_sprite_2d.play("walk")

func _on_timer_timeout():
	can_walk = true


func _on_hurtbox_area_entered(area : Area2D):
	print("Before Death - Collision Enabled?", $CollisionShape2D.disabled)
	print("Before Death - Hurtbox Enabled?", $Hurtbox/CollisionShape2D.disabled)

	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)

	if health_amount <= 0:
		die()  # ✅ Call die() instead of directly removing the enemy

func die():
	print("Enemy Died - Disabling Collision!")

	# ✅ Fully disable ALL collision shapes
	if $CollisionShape2D:
		$CollisionShape2D.set_deferred("disabled", true)
	
	if $Hurtbox/CollisionShape2D:
		$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

	# ✅ Hide the enemy instantly
	$AnimatedSprite2D.visible = false  

	# ✅ Play death effect
	var enemy_death_effect_instance = enemy_death_effect.instantiate() as Node2D
	enemy_death_effect_instance.global_position = global_position
	get_parent().add_child(enemy_death_effect_instance)

	# ✅ Remove enemy after ensuring collision is disabled
	await get_tree().create_timer(0.1).timeout  
	queue_free()

