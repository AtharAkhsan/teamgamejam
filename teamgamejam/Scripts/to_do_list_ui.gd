extends Control

# Daftar to-do dari QuestManager. Buka/tutup dengan tombol "buka_quest" (Q).
# Saat ada to-do baru/selesai, muncul notifikasi singkat di atas layar (walau list tertutup).

const FONT := preload("res://teamgamejam/Assets/Fonts/PIXEARG_.TTF")
const TOAST_DURATION := 3.0

@onready var paper: TextureRect = $Paper
@onready var task_list: VBoxContainer = $Paper/TaskList
@onready var toast: PanelContainer = $Toast
@onready var toast_label: Label = $Toast/Label

var _toast_tween: Tween

func _ready() -> void:
	paper.visible = false
	toast.modulate.a = 0.0
	QuestManager.todo_list_updated.connect(_refresh)
	QuestManager.todo_added.connect(func(task): _show_toast("To-Do baru: %s  (Q)" % task))
	QuestManager.todo_completed.connect(func(task): _show_toast("Selesai: %s!" % task))
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("buka_quest"):
		paper.visible = not paper.visible
		get_viewport().set_input_as_handled()

func _refresh() -> void:
	for child in task_list.get_children():
		child.queue_free()
	for task in QuestManager.active_todos:
		var label := Label.new()
		label.text = "- " + task
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_override("font", FONT)
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color(0.25, 0.12, 0.15))
		task_list.add_child(label)

func _show_toast(text: String) -> void:
	toast_label.text = text
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast, "modulate:a", 1.0, 0.3)
	_toast_tween.tween_interval(TOAST_DURATION)
	_toast_tween.tween_property(toast, "modulate:a", 0.0, 0.5)
