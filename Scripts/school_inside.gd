extends Node2D

func _ready() -> void:
	if GameManager.coming_from_outside:
		$Player.global_position = Vector2(216, 365) # Ganti dengan koordinat pintu dalam
		GameManager.coming_from_outside = false
		
func _on_exit_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		SceneTransition.change_scene("res://teamgamejam/Scenes/Levels/SchoolOutside.tscn")
