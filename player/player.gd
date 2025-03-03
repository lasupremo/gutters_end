extends CharacterBody2D

var bullet = preload("res://player/bullet.tscn")
var player_death_effect = preload("res://player/player_death_effect/player_death_effect.tscn")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var muzzle : Marker2D = $Muzzle

var is_dead = false  # Added: Prevents movement after death


func _ready():
	# Allow the player to collide with collectibles but NOT block enemies
	set_collision_layer_value(2, true)   # Enable Player Layer (for collectibles)
	set_collision_mask_value(3, false)   # Disable enemy-player solid collision
	
	# Allow only the player's HURTBOX (Area2D) to interact with enemies
	$Hurtbox.set_collision_layer_value(4, true)  # Hurtbox on Layer 4
	$Hurtbox.set_collision_mask_value(3, true)   # Detect Enemies

	#print("Player can collect items, and enemies can pass through!")


func player_death():
	if is_dead:  # Prevent multiple calls
		return

	is_dead = true  
	set_physics_process(false)  # Stops physics processing
	set_process_input(false)  # Stops player input

	# Disable state machine to prevent reverting to Idle
	$StateMachine.set_process(false) 

	# Hide the player sprite to avoid conflicts with death animation
	$AnimatedSprite2D.visible = false  

	# Disable collision to prevent interaction
	$CollisionShape2D.set_deferred("disabled", true)  

	# Tell the camera to stop following the player
	if $"../PlayerCamera2D":
		$"../PlayerCamera2D".player = null  

	# Create the death effect instance
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)

	# Wait for the death animation to finish
	await get_tree().create_timer(1.5).timeout  

	# ✅ Now wait 5 seconds before resetting the level
	await get_tree().create_timer(5.0).timeout
	
	# ✅ Reset level and health on death
	SceneManager.transition_to_scene(get_tree().current_scene.scene_file_path, true)
	queue_free()


func _on_hurtbox_body_entered(body : Node2D):
	#print("Hurtbox triggered by:", body.name)
	
	if is_dead:  # Added: Ignore damage if already dead
		return

	if body.is_in_group("Enemy"):
		#print("Enemy entered: ", body.name, " - Damage: ", body.damage_amount)  # Debugging line
		
		#print("Enemy entered ", body.damage_amount)
		
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite_2d, "material:shader_parameter/enabled", true, 0)
		tween.tween_property(animated_sprite_2d, "material:shader_parameter/enabled", false, 0.2)
		
		HealthManager.decrease_health(body.damage_amount)
	
	if HealthManager.current_health == 0:
		player_death()  # Calls player_death() with movement prevention
