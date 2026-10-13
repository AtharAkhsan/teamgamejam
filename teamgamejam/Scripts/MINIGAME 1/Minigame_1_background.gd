extends Node2D

# Latar Minigame 1: luar angkasa -> Bumi makin dekat -> masuk atmosfer.
# Semua digambar lewat kode berdasarkan `progress` (0 = dekat Bulan, 1 = sampai Bumi).

const SIZE := Vector2(480, 270)
const SPACE_COLOR := Color("1b1430")
const ORBIT_COLOR := Color("3b2a5c")
const SKY_COLOR := Color("7ec8f0")
const STAR_COUNT := 70

var progress := 0.0

var _star_pos := PackedVector2Array()
var _star_speed := PackedFloat32Array()
var _star_size := PackedFloat32Array()
var _cloud_pos := PackedVector2Array()
var _cloud_size := PackedFloat32Array()
var _cloud_timer := 0.0
var _land_spots: Array[Vector3] = [] # pulau di Bumi: x, y relatif radius, z = ukuran relatif


func _ready() -> void:
	for i in STAR_COUNT:
		_star_pos.append(Vector2(randf() * SIZE.x, randf() * SIZE.y))
		_star_speed.append(randf_range(0.15, 0.5))
		_star_size.append(1.0 if randf() < 0.8 else 2.0)
	# Pulau di bagian atas Bumi (yang kelihatan di layar), tetap di dalam lingkaran
	for i in 8:
		var p := Vector2.from_angle(randf_range(-PI * 0.85, -PI * 0.15)) * randf_range(0.55, 0.8)
		_land_spots.append(Vector3(p.x, p.y, randf_range(0.06, 0.13)))


# dy = seberapa jauh dunia bergeser ke atas frame ini
func scroll(dy: float, delta: float) -> void:
	for i in _star_pos.size():
		var p := _star_pos[i]
		p.y -= dy * _star_speed[i]
		if p.y < 0.0:
			p = Vector2(randf() * SIZE.x, p.y + SIZE.y)
		_star_pos[i] = p

	# Awan muncul setelah masuk atmosfer
	for i in range(_cloud_pos.size() - 1, -1, -1):
		var c := _cloud_pos[i]
		c.y -= dy * 1.3
		if c.y < -40.0:
			_cloud_pos.remove_at(i)
			_cloud_size.remove_at(i)
		else:
			_cloud_pos[i] = c
	if progress > 0.75:
		_cloud_timer -= delta
		if _cloud_timer <= 0.0:
			_cloud_timer = randf_range(0.25, 0.6)
			_cloud_pos.append(Vector2(randf() * SIZE.x, SIZE.y + 40.0))
			_cloud_size.append(randf_range(8.0, 16.0))
	queue_redraw()


func _draw() -> void:
	var sky_t := smoothstep(0.7, 0.85, progress)
	var bg := SPACE_COLOR.lerp(ORBIT_COLOR, clampf(progress / 0.5, 0.0, 1.0)).lerp(SKY_COLOR, sky_t)
	draw_rect(Rect2(Vector2.ZERO, SIZE), bg)

	# Bintang memudar saat masuk atmosfer
	var star_alpha := 1.0 - smoothstep(0.6, 0.8, progress)
	if star_alpha > 0.0:
		for i in _star_pos.size():
			var s := _star_size[i]
			draw_rect(Rect2(_star_pos[i], Vector2(s, s)), Color(1, 0.95, 1, star_alpha))

	# Bumi naik dari bawah dan membesar, lalu hilang tertutup langit
	var earth_t := inverse_lerp(0.3, 0.8, progress)
	var earth_alpha := 1.0 - smoothstep(0.78, 0.86, progress)
	if earth_t > 0.0 and earth_alpha > 0.0:
		earth_t = minf(earth_t, 1.0)
		var r := lerpf(140.0, 520.0, earth_t)
		var center := Vector2(SIZE.x / 2.0, lerpf(SIZE.y + 120.0, SIZE.y + 300.0, earth_t))
		draw_circle(center, r + 6.0, Color(0.6, 0.85, 1.0, 0.35 * earth_alpha))
		draw_circle(center, r, Color(0.25, 0.45, 0.85, earth_alpha))
		for spot in _land_spots:
			draw_circle(center + Vector2(spot.x, spot.y) * r, spot.z * r, Color(0.35, 0.68, 0.4, earth_alpha))

	for i in _cloud_pos.size():
		var c := _cloud_pos[i]
		var s := _cloud_size[i]
		var col := Color(1, 1, 1, 0.85)
		draw_circle(c, s, col)
		draw_circle(c + Vector2(s * 0.9, s * 0.2), s * 0.75, col)
		draw_circle(c + Vector2(-s * 0.9, s * 0.25), s * 0.7, col)
