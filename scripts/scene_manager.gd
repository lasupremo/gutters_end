extends Node

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

var scenes : Dictionary = { "Level1": "res://levels/level_1.tscn",
							"Level2": "res://levels/level_2.tscn",
							"Level3": "res://levels/level_3.tscn" }

var saved_health: int = 3

func transition_to_scene(level_or_path: String, is_death_reset: bool = false):
	var scene_path: String = scenes.get(level_or_path, level_or_path)
	if scene_path != null:
		# ✅ Save player's health only if NOT dying
		if not is_death_reset:
			saved_health = HealthManager.current_health  # Store current health when changing levels
			print("Saving health:", saved_health)

		# Scene transition effect
		var scene_transition_screen_instance = scene_transition_screen.instantiate()
		get_tree().get_root().add_child(scene_transition_screen_instance)
		await get_tree().create_timer(1.5).timeout  # Adjust as needed
		get_tree().change_scene_to_file(scene_path)
		scene_transition_screen_instance.queue_free()

		# ✅ Restore player's saved health if transitioning levels
		if not is_death_reset:
			HealthManager.load_health(saved_health)
			print("Restored health:", HealthManager.current_health)
		else:
			# ✅ If resetting due to death, reset health
			HealthManager.reset_health()
			print("Reset health due to player death")
