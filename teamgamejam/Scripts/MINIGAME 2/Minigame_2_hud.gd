extends Node2D

signal restart_requested
signal continue_requested

const ASSET_DIR := "res://teamgamejam/Assets/MINI GAME 2/"

var heart_full_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_heart_full.png")
var heart_empty_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_heart_empty.png")
var key_up_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_key_up.png")
var key_down_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_key_down.png")
var gov_id_tex: Texture2D = preload(ASSET_DIR + "Minigame_2_random_gov_id.PNG")
var hearts: Array = []
var game_over_panel: Panel
var restart_button: Button
var game_over_label: Label
var stage_label: Label
var has_won := false


func setup(max_health: int, _current_stage: int):
	for i in range(max_health):
		var heart = TextureRect.new()
		heart.texture = heart_full_tex
		heart.custom_minimum_size = Vector2(40, 40)
		heart.size = Vector2(40, 40)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.position = Vector2(20 + i * 50, 20)
		add_child(heart)
		hearts.append(heart)

	stage_label = Label.new()
	stage_label.text = "DON'T GET CAUGHT!"
	stage_label.add_theme_font_size_override("font_size", 20)
	stage_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	stage_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	stage_label.add_theme_constant_override("shadow_offset_x", 2)
	stage_label.add_theme_constant_override("shadow_offset_y", 2)
	stage_label.position = Vector2(20, 70)
	add_child(stage_label)

	_setup_control_hints()
	_setup_game_over_panel()


func _setup_control_hints():
	var w_rect = TextureRect.new()
	w_rect.texture = key_up_tex
	w_rect.custom_minimum_size = Vector2(48, 48)
	w_rect.size = Vector2(48, 48)
	w_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	w_rect.position = Vector2(1200, 600)
	w_rect.modulate = Color(1, 1, 1, 0.7)
	add_child(w_rect)

	var s_rect = TextureRect.new()
	s_rect.texture = key_down_tex
	s_rect.custom_minimum_size = Vector2(48, 48)
	s_rect.size = Vector2(48, 48)
	s_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	s_rect.position = Vector2(1200, 655)
	s_rect.modulate = Color(1, 1, 1, 0.7)
	add_child(s_rect)


func _setup_game_over_panel():
	game_over_panel = Panel.new()
	game_over_panel.size = Vector2(400, 250)
	game_over_panel.position = Vector2(440, 235)
	game_over_panel.visible = false

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	style.border_color = Color(1, 0.3, 0.3)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	game_over_panel.add_theme_stylebox_override("panel", style)
	add_child(game_over_panel)

	game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.size = Vector2(400, 60)
	game_over_label.position = Vector2(0, 40)
	game_over_panel.add_child(game_over_label)

	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(180, 50)
	restart_button.size = Vector2(180, 50)
	restart_button.position = Vector2(110, 150)
	restart_button.pressed.connect(_on_restart_pressed)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.6, 0.3)
	btn_style.set_corner_radius_all(8)
	restart_button.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.3, 0.75, 0.4)
	btn_hover.set_corner_radius_all(8)
	restart_button.add_theme_stylebox_override("hover", btn_hover)

	restart_button.add_theme_font_size_override("font_size", 22)
	restart_button.add_theme_color_override("font_color", Color.WHITE)
	game_over_panel.add_child(restart_button)


func update_health(health: int):
	for i in range(hearts.size()):
		if i < health:
			hearts[i].texture = heart_full_tex
		else:
			hearts[i].texture = heart_empty_tex



func show_game_over():
	if game_over_panel:
		game_over_panel.visible = true

func show_game_won():
	if game_over_panel:
		has_won = true
		game_over_label.text = "What's This?"
		game_over_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2)) # Green color
		var style = game_over_panel.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			style.border_color = Color(0.2, 1.0, 0.2)

		restart_button.text = ""
		restart_button.icon = gov_id_tex
		restart_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		restart_button.expand_icon = true
		var clear_style = StyleBoxEmpty.new()
		restart_button.add_theme_stylebox_override("normal", clear_style)
		restart_button.add_theme_stylebox_override("hover", clear_style)
		restart_button.size = Vector2(180, 100)
		restart_button.position = Vector2(110, 115)

		game_over_panel.visible = true

# Tombol yang sama dipakai untuk "RESTART" (kalah) dan KTP (menang)
func _on_restart_pressed():
	if has_won:
		restart_button.disabled = true
		continue_requested.emit()
	else:
		restart_requested.emit()
