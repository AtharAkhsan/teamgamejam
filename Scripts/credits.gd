extends Control

@onready var click_sfx = $clickSFX
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@export var scroll_speed = 50 # Kecepatan jalan (pixel per detik)

var speed = 50 # Kecepatan scroll

func _ready():
	# get_viewport_rect().size.y adalah tinggi layar game kamu (misal 648 atau 1080)
	rich_text_label.position.y = get_viewport_rect().size.y
	
	
func _process(delta):
	rich_text_label.position.y -= scroll_speed * delta
	
	if rich_text_label.position.y < -rich_text_label.size.y:
		rich_text_label.position.y = get_viewport_rect().size.y
		
func _on_button_back_pressed() -> void:
	click_sfx.play()
	await click_sfx.finished
	SceneTransition.change_scene("res://teamgamejam/Scenes/Controls/main_menu.tscn")
