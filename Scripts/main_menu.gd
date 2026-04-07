extends Control

@onready var click_sfx = $clickSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_menu_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_start_pressed() -> void:
	click_sfx.play()
	await click_sfx.finished
	SceneTransition.change_scene("res://teamgamejam/Scenes/game_test.tscn")

func _on_exit_pressed() -> void:
	click_sfx.play()	
	await click_sfx.finished
	get_tree().quit()


func _on_button_credits_pressed() -> void:
	click_sfx.play()
	await click_sfx.finished
	SceneTransition.change_scene("res://teamgamejam/Scenes/Controls/credits.tscn")
