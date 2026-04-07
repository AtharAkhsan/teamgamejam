extends CanvasLayer

@onready var anim_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready():
	# Pastikan saat game mulai, layar hitam ini tidak memblokir apa-apa
	color_rect.visible = false 

func change_scene(target_path: String):
	# 1. Munculkan ColorRect agar animasi terlihat & memblokir klik saat transisi
	color_rect.visible = true 
	
	anim_player.play("fade_to_black")
	await anim_player.animation_finished
	
	get_tree().change_scene_to_file(target_path)
	
	anim_player.play_backwards("fade_to_black")
	await anim_player.animation_finished
	
	# 2. Sembunyikan lagi setelah selesai agar player bisa klik tombol
	color_rect.visible = false
