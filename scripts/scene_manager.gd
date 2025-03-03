extends Node

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

var scenes: Dictionary = {
	"TutorialLevel": "res://levels/tutorial_level.tscn",
	"Level1": "res://levels/level_1.tscn",
	"Level2": "res://levels/level_2.tscn",
	"Level3": "res://levels/level_3.tscn"
}

var saved_health: int = 3  # Stores player's health when transitioning normally

func transition_to_scene(level_or_path: String, is_death_reset: bool = false):
	var scene_path: String = scenes.get(level_or_path, level_or_path)
	if scene_path != null:
		# ✅ If the player died, reset health before restarting the level
		if is_death_reset:
			HealthManager.reset_health()
			print("Player died - Health reset to max")
		else:
			# ✅ Save player's health if NOT dying
			saved_health = HealthManager.current_health
			print("Saving health:", saved_health)

		# Scene transition effect
		var scene_transition_screen_instance = scene_transition_screen.instantiate()
		get_tree().get_root().add_child(scene_transition_screen_instance)
		await get_tree().create_timer(1.5).timeout  # Adjust as needed
		get_tree().change_scene_to_file(scene_path)
		scene_transition_screen_instance.queue_free()

		# ✅ Restore saved health only if NOT a death reset
		if not is_death_reset:
			HealthManager.current_health = saved_health
			print("Restored health:", HealthManager.current_health)

		# ✅ Ensure UI updates after transition
		var game_screen = get_tree().get_root().find_child("GameScreen", true, false)  
		if game_screen:
			game_screen.update_health_display(HealthManager.current_health)
			print("Forced UI update - Health:", HealthManager.current_health)
		else:
			print("Warning: GameScreen not found, UI may not update.")
