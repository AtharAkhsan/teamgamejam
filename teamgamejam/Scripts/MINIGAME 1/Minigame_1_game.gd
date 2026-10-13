extends Control

# Minigame 1: Lulu meluncur dari Bulan ke Bumi sebagai meteor (antara SCENE 07 dan 08).
# Gerak kiri/kanan untuk menghindari asteroid & satelit. Dunia dirender di 480x270
# lalu diperbesar 4x (SubViewportContainer.stretch_shrink) supaya terlihat pixel art.

# Setelah sampai Bumi: lanjut cutscene tabrakan di sekolah, lalu minigame kejar-kejaran
const NEXT_TIMELINE := "IntroBumi"
const NEXT_SCENE := "res://teamgamejam/Scenes/MINIGAME 2/Minigame_2_game.tscn"

const WORLD_SIZE := Vector2(480, 270)
const MOON_EARTH_KM := 384400
const ObstacleScript := preload("res://teamgamejam/Scripts/MINIGAME 1/Minigame_1_obstacle.gd")
const MINIGAME_MUSIC := preload("res://teamgamejam/Assets/Audio/Songs/Minigame 1.mp3")
const SFX_HIT := preload("res://teamgamejam/Assets/MINI GAME 2/Minigame_2_sfx_hit.wav")
const SFX_GAMEOVER := preload("res://teamgamejam/Assets/MINI GAME 2/Minigame_2_sfx_gameover.wav")

# Batas fase (progress 0..1) untuk banner dan jenis rintangan
const PHASES := [
	{"until": 0.35, "name": "Luar Angkasa"},
	{"until": 0.75, "name": "Orbit Bumi"},
	{"until": 1.01, "name": "Atmosfer Bumi!"},
]

@export var total_distance := 9000.0 # px dunia sampai Bumi (~60 detik)
@export var start_speed := 90.0
@export var end_speed := 210.0
@export var start_spawn_interval := 0.9
@export var end_spawn_interval := 0.35
@export var max_health := 3

var distance := 0.0
var health := 3
var is_over := false
var spawn_timer := 1.5 # jeda sebelum rintangan pertama
var shake_timer := 0.0
var current_phase := -1

@onready var world: SubViewportContainer = $World
@onready var background = $World/Viewport/Background
@onready var obstacles: Node2D = $World/Viewport/Obstacles
@onready var meteor = $World/Viewport/Meteor
@onready var hud = $HUD
@onready var sfx: AudioStreamPlayer = $SfxPlayer


func _ready() -> void:
	health = max_health
	hud.setup(max_health)
	hud.restart_requested.connect(restart_game)
	MusicManager.play_music(MINIGAME_MUSIC)


func _process(delta: float) -> void:
	_update_shake(delta)
	if is_over:
		return

	var progress := get_progress()
	var dy := lerpf(start_speed, end_speed, progress) * delta
	distance += dy

	background.progress = progress
	background.scroll(dy, delta)
	_update_phase(progress)
	_move_obstacles(dy)
	_check_collisions()
	_update_spawning(delta, progress)
	hud.update_distance(roundi(MOON_EARTH_KM * (1.0 - progress)), progress)

	if progress >= 1.0:
		_win()


func get_progress() -> float:
	return clampf(distance / total_distance, 0.0, 1.0)


func _update_phase(progress: float) -> void:
	for i in PHASES.size():
		if progress < PHASES[i]["until"]:
			if i != current_phase:
				current_phase = i
				hud.show_banner(PHASES[i]["name"])
			return


func _move_obstacles(dy: float) -> void:
	for obs in obstacles.get_children():
		obs.position.y -= dy
		if obs.position.y < -40.0:
			obs.queue_free()


func _check_collisions() -> void:
	if meteor.is_invincible():
		return
	for obs in obstacles.get_children():
		if meteor.position.distance_to(obs.position) < meteor.RADIUS + obs.hit_radius():
			_on_hit()
			return


func _update_spawning(delta: float, progress: float) -> void:
	# Berhenti spawn menjelang mendarat supaya akhirnya bersih
	if progress > 0.95:
		return
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	spawn_timer = lerpf(start_spawn_interval, end_spawn_interval, progress) * randf_range(0.8, 1.2)

	var count := 2 if progress > 0.55 and randf() < 0.4 else 1
	var margin := 15.0
	var lane_width := WORLD_SIZE.x - margin * 2.0
	var first := randf() * lane_width
	for i in count:
		var u := first
		if i == 1:
			# Geser minimal 90px (melingkar) supaya selalu ada celah di antaranya
			u = fposmod(first + randf_range(90.0, lane_width - 90.0), lane_width)
		_spawn_obstacle(Vector2(margin + u, WORLD_SIZE.y + 30.0), progress)


func _spawn_obstacle(pos: Vector2, progress: float) -> void:
	var obs := Node2D.new()
	obs.set_script(ObstacleScript)
	obs.position = pos
	if progress > 0.3 and randf() < 0.35:
		obs.setup(ObstacleScript.Kind.SATELLITE, 11.0)
	else:
		obs.setup(ObstacleScript.Kind.ASTEROID, randf_range(7.0, 15.0))
	obstacles.add_child(obs)


func _on_hit() -> void:
	health -= 1
	meteor.take_hit()
	hud.update_health(health)
	shake_timer = 0.3
	_play_sfx(SFX_HIT)
	if health <= 0:
		_game_over()


func _update_shake(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer -= delta
		world.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 16.0 * (shake_timer / 0.3)
	else:
		world.position = Vector2.ZERO


func _play_sfx(stream: AudioStream) -> void:
	sfx.stream = stream
	sfx.play()


func _game_over() -> void:
	is_over = true
	meteor.is_active = false
	_play_sfx(SFX_GAMEOVER)
	hud.show_game_over()


func restart_game() -> void:
	get_tree().reload_current_scene()


# Sampai di Bumi: kilatan putih, layar hitam, lalu cutscene IntroBumi
func _win() -> void:
	is_over = true
	meteor.is_active = false
	await hud.flash_in()
	world.visible = false
	MusicManager.stop_music()
	await hud.flash_out()
	hud.visible = false
	Dialogic.timeline_ended.connect(_on_story_timeline_ended, CONNECT_ONE_SHOT)
	Dialogic.start(NEXT_TIMELINE)


func _on_story_timeline_ended() -> void:
	Dialogic.Audio.stop_all_channels()
	SceneTransition.change_scene(NEXT_SCENE)
