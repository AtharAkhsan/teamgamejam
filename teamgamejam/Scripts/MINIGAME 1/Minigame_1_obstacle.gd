extends Node2D

# Rintangan selama jatuh: asteroid atau satelit.
# Sementara digambar lewat kode; bisa diganti sprite nanti.

enum Kind { ASTEROID, SATELLITE }

var kind: Kind = Kind.ASTEROID
var radius := 10.0
var drift_x := 0.0
var spin := 0.0
var _points := PackedVector2Array()
var _craters: Array[Vector3] = [] # x, y = posisi, z = radius


func setup(p_kind: Kind, p_radius: float) -> void:
	kind = p_kind
	radius = p_radius
	if kind == Kind.ASTEROID:
		spin = randf_range(-1.5, 1.5)
		var n := 9
		for i in n:
			_points.append(Vector2.from_angle(TAU * i / n) * radius * randf_range(0.75, 1.1))
		for i in 2:
			var p := Vector2.from_angle(randf() * TAU) * radius * 0.4
			_craters.append(Vector3(p.x, p.y, maxf(1.5, radius * 0.22)))
	else:
		drift_x = randf_range(-40.0, 40.0)
		spin = randf_range(-0.6, 0.6)
	queue_redraw()


# Radius tabrakan (satelit tipis, jadi lebih kecil dari ukuran gambarnya)
func hit_radius() -> float:
	return radius * (0.85 if kind == Kind.ASTEROID else 0.6)


func _process(delta: float) -> void:
	position.x += drift_x * delta
	rotation += spin * delta


func _draw() -> void:
	if kind == Kind.ASTEROID:
		draw_colored_polygon(_points, Color(0.52, 0.47, 0.6))
		var outline := _points.duplicate()
		outline.append(_points[0])
		draw_polyline(outline, Color(0.3, 0.25, 0.38), 1.0)
		for c in _craters:
			draw_circle(Vector2(c.x, c.y), c.z, Color(0.42, 0.37, 0.5))
	else:
		var panel := Color(0.3, 0.5, 0.95)
		draw_rect(Rect2(-radius, -2, radius - 4, 4), panel)
		draw_rect(Rect2(4, -2, radius - 4, 4), panel)
		draw_rect(Rect2(-3, -3, 6, 6), Color(0.8, 0.8, 0.85))
		draw_line(Vector2(0, -3), Vector2(0, -7), Color(0.8, 0.8, 0.85), 1.0)
		draw_rect(Rect2(-1, -8, 2, 2), Color(1, 0.3, 0.3))
