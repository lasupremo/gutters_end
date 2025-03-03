extends CanvasLayer

@onready var collectible_label = $MarginContainer/VBoxContainer/HBoxContainer/CollectibleLabel
@onready var health_bar = $MarginContainer/VBoxContainer/Control/HealthBar

func _ready():
	CollectibleManager.on_collectible_award_received.connect(on_collectible_award_received)
	HealthManager.on_health_changed.connect(update_health_display)  # ✅ Connect health update

	# ✅ Force health UI update on level load
	update_health_display(HealthManager.current_health)
	print("Game Screen UI refreshed on level load - Health:", HealthManager.current_health)

func on_collectible_award_received(total_award : int):
	collectible_label.text = str(total_award)

func update_health_display(new_health: int):
	if health_bar:
		health_bar.on_player_health_changed(new_health)  # ✅ Manually update UI
		print("✅ Forced HealthBar UI update:", new_health)
	else:
		print("❌ ERROR: HealthBar not found!")

func _on_pause_texture_button_pressed():
	GameManager.pause_game()
