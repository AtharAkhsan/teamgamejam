extends CanvasLayer

# HUD Minigame 1 (resolusi penuh 1920x1080, di atas dunia yang di-scale 4x)

signal restart_requested

const FONT := preload("res://teamgamejam/Assets/Fonts/PIXEARG_.TTF")
const HEART_FULL := preload("res://teamgamejam/Assets/MINI GAME 2/Minigame_2_heart_full.png")
const HEART_EMPTY := preload("res://teamgamejam/Assets/MINI GAME 2/Minigame_2_heart_empty.png")
const BAR_WIDTH := 360.0

var hearts: Array[TextureRect] = []
var distance_label: Label
var bar_fill: ColorRect
var banner_label: Label
var game_over_panel: PanelContainer
var restart_button: Button
var flash: ColorRect


func setup(max_health: int) -> void:
	var heart_box := HBoxContainer.new()
	heart_box.position = Vector2(40, 40)
	heart_box.add_theme_constant_override("separation", 12)
	add_child(heart_box)
	for i in max_health:
		var heart := TextureRect.new()
		heart.texture = HEART_FULL
		heart.custom_minimum_size = Vector2(52, 40)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart_box.add_child(heart)
		hearts.append(heart)

	var title := _make_label("Jarak ke Bumi", 26)
	title.position = Vector2(1920 - 40 - BAR_WIDTH, 34)
	add_child(title)
	distance_label = _make_label("", 44)
	distance_label.position = Vector2(1920 - 40 - BAR_WIDTH, 66)
	add_child(distance_label)

	var bar_bg := ColorRect.new()
	bar_bg.color = Color(0, 0, 0, 0.45)
	bar_bg.position = Vector2(1920 - 40 - BAR_WIDTH, 130)
	bar_bg.size = Vector2(BAR_WIDTH, 14)
	add_child(bar_bg)
	bar_fill = ColorRect.new()
	bar_fill.color = Color(1.0, 0.7, 0.25)
	bar_fill.size = Vector2(0, 14)
	bar_bg.add_child(bar_fill)

	banner_label = _make_label("", 64)
	banner_label.add_theme_color_override("font_color", Color(1, 0.88, 0.35))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.size = Vector2(1920, 80)
	banner_label.position = Vector2(0, 440)
	banner_label.modulate.a = 0.0
	add_child(banner_label)

	var hint := _make_label("← / →  atau  A / D  untuk menghindar", 32)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(1920, 50)
	hint.position = Vector2(0, 960)
	add_child(hint)
	var hint_tween := create_tween()
	hint_tween.tween_interval(4.0)
	hint_tween.tween_property(hint, "modulate:a", 0.0, 1.0)

	_setup_game_over_panel()

	flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.modulate.a = 0.0
	add_child(flash)


func _make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.15))
	label.add_theme_constant_override("outline_size", 8)
	return label


func _setup_game_over_panel() -> void:
	game_over_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	style.border_color = Color(1, 0.3, 0.3)
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	style.set_content_margin_all(40)
	game_over_panel.add_theme_stylebox_override("panel", style)
	game_over_panel.custom_minimum_size = Vector2(600, 0)
	game_over_panel.position = Vector2(660, 340)
	game_over_panel.visible = false
	add_child(game_over_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 30)
	game_over_panel.add_child(box)

	var label := _make_label("GAME OVER", 64)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)
	var sub := _make_label("Lulu terpental kembali ke luar angkasa...", 26)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)

	restart_button = Button.new()
	restart_button.text = "COBA LAGI"
	restart_button.custom_minimum_size = Vector2(0, 80)
	restart_button.add_theme_font_override("font", FONT)
	restart_button.add_theme_font_size_override("font_size", 36)
	restart_button.pressed.connect(func(): restart_requested.emit())
	box.add_child(restart_button)


func update_health(health: int) -> void:
	for i in hearts.size():
		hearts[i].texture = HEART_FULL if i < health else HEART_EMPTY


# km = sisa jarak yang ditampilkan, progress = 0..1
func update_distance(km: int, progress: float) -> void:
	distance_label.text = format_km(km)
	bar_fill.size.x = BAR_WIDTH * progress


func show_banner(text: String) -> void:
	banner_label.text = text
	var tween := create_tween()
	tween.tween_property(banner_label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.6)
	tween.tween_property(banner_label, "modulate:a", 0.0, 0.6)


func show_game_over() -> void:
	game_over_panel.visible = true
	restart_button.grab_focus()


# Kilatan putih saat menghantam Bumi. Bisa di-await.
func flash_in() -> void:
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 1.0, 0.35)
	await tween.finished


func flash_out() -> void:
	var tween := create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)
	await tween.finished


static func format_km(value: int) -> String:
	var digits := str(value)
	var out := ""
	while digits.length() > 3:
		out = "." + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return digits + out + " km"
