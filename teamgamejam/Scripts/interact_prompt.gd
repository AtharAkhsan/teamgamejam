extends Node2D

# Prompt tombol "E" kecil di atas kepala NPC yang bisa diajak bicara.
# Pasang interact_prompt.tscn sebagai child NPC, lalu atur `visible` dari script NPC.
# Digambar per piksel (koordinat dunia) supaya cocok dengan pixel art game.

const KEY_COLOR := Color(0.96, 0.94, 0.88)
const KEY_SHADE := Color(0.7, 0.66, 0.6)
const OUTLINE := Color(0.18, 0.12, 0.2)
# Huruf "E" 3x5 piksel
const GLYPH := ["###", "#..", "##.", "#..", "###"]

@export var bob_height := 1.0
@export var bob_speed := 4.0

var _time := 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	var y := roundf(sin(_time * bob_speed) * bob_height)
	var origin := Vector2(-4, -4 + y)
	# Keycap 9x9: outline, sisi bawah lebih gelap, permukaan terang
	draw_rect(Rect2(origin, Vector2(9, 9)), OUTLINE)
	draw_rect(Rect2(origin + Vector2(1, 1), Vector2(7, 7)), KEY_SHADE)
	draw_rect(Rect2(origin + Vector2(1, 1), Vector2(7, 6)), KEY_COLOR)
	for row in GLYPH.size():
		for col in GLYPH[row].length():
			if GLYPH[row][col] == "#":
				draw_rect(Rect2(origin + Vector2(3 + col, 1 + row), Vector2.ONE), OUTLINE)
