extends Node2D


func _on_inside_door_body_entered(body: Node2D) -> void:
	GameManager.coming_from_outside = true
	if body.name == "Player":
		SceneTransition.change_scene("res://teamgamejam/Scenes/Levels/SchoolInside.tscn")
