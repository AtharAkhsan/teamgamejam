extends Control

# Daftar to-do dari QuestManager. Buka/tutup dengan tombol "buka_quest" (Q)

const FONT := preload("res://teamgamejam/Assets/Fonts/PIXEARG_.TTF")

@onready var task_list: VBoxContainer = $Paper/TaskList

func _ready() -> void:
	visible = false
	QuestManager.todo_list_updated.connect(_refresh)
	_refresh()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("buka_quest"):
		visible = not visible
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
