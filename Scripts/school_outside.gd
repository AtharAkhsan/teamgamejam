extends Node2D

const LEVEL_MUSIC := preload("res://teamgamejam/Assets/Audio/Songs/Main Loop.mp3")

func _ready() -> void:
	MusicManager.play_music(LEVEL_MUSIC)

func _on_inside_door_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.coming_from_outside = true
		SceneTransition.change_scene("res://teamgamejam/Scenes/Levels/SchoolInside.tscn")
