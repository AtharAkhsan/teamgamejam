extends Control

# Setelah cutscene Intro ("ADA ALIENN!!! KEJAR DIAA!!!") langsung ke minigame kejar-kejaran
const AFTER_INTRO_SCENE := "res://teamgamejam/Scenes/MINIGAME 2/Minigame_2_game.tscn"

@onready var click_sfx = $clickSFX
@onready var buttons: VBoxContainer = $VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_menu_music()

func _on_start_pressed() -> void:
	_set_buttons_disabled(true)
	click_sfx.play()
	await click_sfx.finished
	MusicManager.stop_music()
	# Sembunyikan menu supaya tidak kelihatan sekilas waktu cutscene selesai
	hide()
	Dialogic.timeline_ended.connect(_on_intro_finished, CONNECT_ONE_SHOT)
	Dialogic.start("Intro")

func _on_intro_finished() -> void:
	Dialogic.Audio.stop_all_channels()
	SceneTransition.change_scene(AFTER_INTRO_SCENE)

func _on_exit_pressed() -> void:
	_set_buttons_disabled(true)
	click_sfx.play()
	await click_sfx.finished
	get_tree().quit()


func _on_button_credits_pressed() -> void:
	_set_buttons_disabled(true)
	click_sfx.play()
	await click_sfx.finished
	SceneTransition.change_scene("res://teamgamejam/Scenes/Controls/credits.tscn")

func _set_buttons_disabled(value: bool) -> void:
	for button in buttons.get_children():
		if button is Button:
			button.disabled = value
