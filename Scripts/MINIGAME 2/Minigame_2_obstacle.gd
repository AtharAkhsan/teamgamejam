extends Area2D


func _ready():
	add_to_group("obstacles")


func set_obstacle_texture(tex: Texture2D):
	if tex and has_node("Sprite2D"):
		$Sprite2D.texture = tex
		var target_h = 70.0
		var s = target_h / tex.get_height()
		$Sprite2D.scale = Vector2(s, s)
		# Adjust collision shape to match
		if has_node("CollisionShape2D"):
			var shape = RectangleShape2D.new()
			shape.size = Vector2(tex.get_width() * s * 0.8, tex.get_height() * s * 0.8)
			$CollisionShape2D.shape = shape
