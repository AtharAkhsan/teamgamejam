extends Node2D

# Lulu dalam wujud meteor (lihat SCENE 07). Sementara digambar lewat kode,
# ganti _draw() dengan Sprite2D kalau artist sudah bikin sprite-nya.

signal hit

const RADIUS := 8.0
const INVINCIBLE_DURATION := 1.5

@export var move_speed := 230.0
@export var acceleration := 1400.0

# Batas gerak horizontal (dalam resolusi dunia 480x270)
var min_x := 14.0
var max_x := 466.0
var velocity_x := 0.0
var is_active := true
var invincible_timer := 0.0


func _process(delta: float) -> void:
	var dir := 0.0
	if is_active:
		dir = Input.get_axis("left", "right")
	velocity_x = move_toward(velocity_x, dir * move_speed, acceleration * delta)
	position.x = clampf(position.x + velocity_x * delta, min_x, max_x)

	if invincible_timer > 0.0:
		invincible_timer -= delta
	# Kedip-kedip selama kebal setelah kena
	visible = invincible_timer <= 0.0 or fmod(invincible_timer, 0.2) > 0.1
	queue_redraw()


func is_invincible() -> bool:
	return invincible_timer > 0.0


func take_hit() -> void:
	invincible_timer = INVINCIBLE_DURATION
	hit.emit()


func _draw() -> void:
	var flicker := 1.0 + sin(Time.get_ticks_msec() * 0.025) * 0.08
	# Bola api
	draw_circle(Vector2.ZERO, (RADIUS + 5.0) * flicker, Color(1.0, 0.45, 0.1, 0.45))
	draw_circle(Vector2.ZERO, (RADIUS + 2.0) * flicker, Color(1.0, 0.72, 0.25))
	draw_circle(Vector2.ZERO, RADIUS - 1.0, Color(1.0, 0.95, 0.7))
	# Lulu di dalamnya
	draw_circle(Vector2(0, 1), RADIUS - 3.0, Color(0.56, 0.82, 0.45))
	draw_rect(Rect2(-3, 0, 2, 2), Color(0.45, 0.1, 0.15))
	draw_rect(Rect2(1, 0, 2, 2), Color(0.45, 0.1, 0.15))
