extends Node2D

# Lane Y positions (3 lanes)
const LANE_Y := [380.0, 460.0, 530.0]
const LUNA_X := 200.0
const MOB_X := 50.0

# 5 difficulty stages
const STAGES = [
	{"speed": 200.0, "spawn_min": 2.2, "spawn_max": 3.0, "threshold": 0.0},
	{"speed": 280.0, "spawn_min": 1.7, "spawn_max": 2.5, "threshold": 500.0},
	{"speed": 360.0, "spawn_min": 1.3, "spawn_max": 2.0, "threshold": 1200.0},
	{"speed": 440.0, "spawn_min": 1.0, "spawn_max": 1.5, "threshold": 2200.0},
	{"speed": 520.0, "spawn_min": 0.6, "spawn_max": 1.0, "threshold": 3500.0},
]

const MAX_DISTANCE: float = 20000.0

# Minigame ini didesain untuk resolusi 1280x720, lalu di-scale ke viewport project
const DESIGN_HEIGHT := 720.0

# Setelah menang: lanjut ke cutscene MendaratSekolah, lalu masuk ke sekolah
const NEXT_TIMELINE := "MendaratSekolah"
const NEXT_SCENE := "res://teamgamejam/Scenes/Levels/SchoolOutside.tscn"

const ASSET_DIR := "res://teamgamejam/Assets/MINI GAME 2/"
const LunaScene := preload("res://teamgamejam/Scenes/MINIGAME 2/Minigame_2_luna.tscn")
const ObstacleScene := preload("res://teamgamejam/Scenes/MINIGAME 2/Minigame_2_obstacle.tscn")
const HudScript := preload("res://teamgamejam/Scripts/MINIGAME 2/Minigame_2_hud.gd")
const MINIGAME_MUSIC := preload("res://teamgamejam/Assets/Audio/Songs/Minigame 2.mp3")

var scroll_speed: float = 200.0
var current_stage: int = 0
var distance_traveled: float = 0.0
var health: int = 3
var max_health: int = 3
var is_game_over: bool = false

# Resources
var obstacle_textures: Array[Texture2D] = [
	preload(ASSET_DIR + "Minigame_2_ME_Singles_Vehicles_16x16_Ambulance_Left_1.png"),
	preload(ASSET_DIR + "Minigame_2_ME_Singles_Vehicles_16x16_Car_Left_6.png"),
	preload(ASSET_DIR + "Minigame_2_ME_Singles_Vehicles_16x16_Car_Left_13.png"),
	preload(ASSET_DIR + "Minigame_2_ME_Singles_Vehicles_16x16_Car_Left_14.png"),
	preload(ASSET_DIR + "Minigame_2_obstacle_car.png"),
]

# Sounds
var sfx_hit: AudioStream = preload(ASSET_DIR + "Minigame_2_sfx_hit.wav")
var sfx_switch: AudioStream = preload(ASSET_DIR + "Minigame_2_sfx_switch.wav")
var sfx_gameover: AudioStream = preload(ASSET_DIR + "Minigame_2_sfx_gameover.wav")

# Node references
var luna_node: Area2D
var mob_sprite: Sprite2D
var obstacle_container: Node2D
var spawn_timer: Timer
var hud_layer: CanvasLayer
var hud_controller: Node2D
var sfx_player: AudioStreamPlayer

# Background scrolling
var bg_sprites: Array = []
var bg_width: float = 1280.0


func _ready():
	_setup_background()
	_setup_ground()
	_setup_luna()
	_setup_mob()
	_setup_obstacles()
	_setup_hud()
	_setup_audio()
	_fit_to_viewport()
	MusicManager.play_music(MINIGAME_MUSIC)


# Scale layout 1280x720 ke ukuran viewport project (1920x1080)
func _fit_to_viewport():
	var s := get_viewport_rect().size.y / DESIGN_HEIGHT
	scale = Vector2(s, s)
	hud_layer.scale = Vector2(s, s)


func _setup_background():
	var bg_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_bg_city.png")

	# Zoom into the street/storefront section of the city background
	# bg_city.png is 2592x672; we crop to include the street and storefronts
	var region_rect = Rect2(0, 190, 2592, 240)
	var cropped_tex = AtlasTexture.new()
	cropped_tex.atlas = bg_tex
	cropped_tex.region = region_rect

	var scale_y = 720.0 / cropped_tex.get_height()
	bg_width = cropped_tex.get_width() * scale_y

	for i in range(3):
		var spr = Sprite2D.new()
		spr.texture = cropped_tex
		spr.centered = false
		spr.scale = Vector2(scale_y, scale_y)
		spr.position.x = i * bg_width
		spr.z_index = -10
		add_child(spr)
		bg_sprites.append(spr)


func _setup_ground():
	# Play area is now transparent - no gray box overlay
	# Only add subtle lane dividers for visual guidance
	for i in range(2):
		var divider = ColorRect.new()
		divider.color = Color(1, 1, 0.7, 0.15)
		divider.size = Vector2(1280, 1)
		divider.position = Vector2(0, (LANE_Y[i] + LANE_Y[i + 1]) / 2.0)
		divider.z_index = -4
		add_child(divider)


func _setup_luna():
	luna_node = LunaScene.instantiate()
	luna_node.position = Vector2(LUNA_X, LANE_Y[1])
	luna_node.lane_positions = LANE_Y
	luna_node.hit.connect(_on_luna_hit)
	luna_node.lane_changed.connect(_on_luna_lane_changed)
	luna_node.z_index = 5
	add_child(luna_node)


func _setup_mob():
	mob_sprite = Sprite2D.new()
	var mob_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_mob.png")
	mob_sprite.texture = mob_tex
	var target_h = 140.0
	var s = target_h / mob_tex.get_height()
	mob_sprite.scale = Vector2(s, s)
	mob_sprite.position = Vector2(MOB_X, LANE_Y[1])
	mob_sprite.z_index = 2
	add_child(mob_sprite)


func _setup_obstacles():
	obstacle_container = Node2D.new()
	obstacle_container.name = "Obstacles"
	add_child(obstacle_container)

	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	spawn_timer.timeout.connect(_on_spawn_timeout)
	add_child(spawn_timer)
	_restart_spawn_timer()


func _setup_hud():
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HUD"
	add_child(hud_layer)

	hud_controller = HudScript.new()
	hud_controller.name = "HUDController"
	hud_layer.add_child(hud_controller)
	hud_controller.setup(max_health, current_stage)
	hud_controller.restart_requested.connect(restart_game)
	hud_controller.continue_requested.connect(_continue_story)


func _setup_audio():
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	add_child(sfx_player)


func _play_sfx(stream: AudioStream):
	if stream and sfx_player:
		sfx_player.stream = stream
		sfx_player.play()


func _process(delta: float):
	if is_game_over:
		return

	distance_traveled += scroll_speed * delta
	
	if distance_traveled >= MAX_DISTANCE:
		_trigger_game_won()
		return

	_update_stage()
	_scroll_background(delta)
	_move_obstacles(delta)
	_animate_mob(delta)


func _update_stage():
	for i in range(STAGES.size() - 1, -1, -1):
		if distance_traveled >= STAGES[i]["threshold"]:
			if current_stage != i:
				current_stage = i
				scroll_speed = STAGES[i]["speed"]
				if hud_controller and hud_controller.has_method("update_stage"):
					hud_controller.update_stage(current_stage)
			break


func _scroll_background(delta: float):
	if bg_sprites.is_empty():
		return
	for spr in bg_sprites:
		spr.position.x -= scroll_speed * 0.3 * delta
		if spr.position.x <= -bg_width:
			var max_x = -INF
			for s in bg_sprites:
				if s.position.x > max_x:
					max_x = s.position.x
			spr.position.x = max_x + bg_width


func _move_obstacles(delta: float):
	for obs in obstacle_container.get_children():
		obs.position.x -= scroll_speed * delta
		if obs.position.x < -200:
			obs.queue_free()


func _animate_mob(delta: float):
	if mob_sprite:
		mob_sprite.position.y = lerp(mob_sprite.position.y, luna_node.position.y, 3.0 * delta)
		mob_sprite.position.x = MOB_X + sin(Time.get_ticks_msec() * 0.005) * 8.0


func _restart_spawn_timer():
	var stage = STAGES[current_stage]
	spawn_timer.start(randf_range(stage["spawn_min"], stage["spawn_max"]))


func _on_spawn_timeout():
	if is_game_over:
		return
	_spawn_obstacles()
	_restart_spawn_timer()


func _spawn_obstacles():
	var num_blocked = 1
	if current_stage >= 2:
		num_blocked = randi_range(1, 2)

	var available = [0, 1, 2]
	var blocked: Array = []

	for i in range(num_blocked):
		if available.size() <= 1:
			break
		var idx = randi() % available.size()
		blocked.append(available[idx])
		available.remove_at(idx)

	for lane in blocked:
		var obs = ObstacleScene.instantiate()
		obs.position = Vector2(1400.0 + randf() * 100.0, LANE_Y[lane])
		if obstacle_textures.size() > 0:
			obs.set_obstacle_texture(obstacle_textures[randi() % obstacle_textures.size()])
		obs.z_index = 3
		obstacle_container.add_child(obs)


func _on_luna_hit():
	if is_game_over:
		return
	health -= 1
	_play_sfx(sfx_hit)
	if hud_controller and hud_controller.has_method("update_health"):
		hud_controller.update_health(health)
	if health <= 0:
		_trigger_game_over()


func _on_luna_lane_changed():
	_play_sfx(sfx_switch)


func _trigger_game_over():
	is_game_over = true
	if luna_node:
		luna_node.is_active = false
	spawn_timer.stop()
	_play_sfx(sfx_gameover)
	if hud_controller and hud_controller.has_method("show_game_over"):
		hud_controller.show_game_over()


func _trigger_game_won():
	is_game_over = true
	if luna_node:
		luna_node.is_active = false
	spawn_timer.stop()
	# Can optionally play a win sfx here if available
	if hud_controller and hud_controller.has_method("show_game_won"):
		hud_controller.show_game_won()


func restart_game():
	get_tree().reload_current_scene()


# Dipanggil saat pemain klik KTP setelah menang
func _continue_story():
	hud_layer.visible = false
	MusicManager.stop_music()
	Dialogic.timeline_ended.connect(_on_story_timeline_ended, CONNECT_ONE_SHOT)
	Dialogic.start(NEXT_TIMELINE)


func _on_story_timeline_ended():
	Dialogic.Audio.stop_all_channels()
	SceneTransition.change_scene(NEXT_SCENE)
