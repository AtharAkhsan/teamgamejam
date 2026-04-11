extends Node2D

@onready var video_player = $IntroVideo

func _ready():
	# 1. Mulai Video Pertama
	play_intro_video("res://teamgamejam/Assets/Videos/INTRO LUNA 1.ogv")
	
	# 2. Tunggu 2 detik, baru jalankan Dialogic
	await get_tree().create_timer(2.0).timeout
	# Jalankan timeline Dialogic (Teks akan muncul di atas video yang masih jalan)
	Dialogic.start("IntroTimeline")
	
	# Hubungkan signal dari Dialogic (untuk pemicu video kedua)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
func play_intro_video(path: String):
	video_player.stream = load(path)
	video_player.play()
	video_player.show()

func _on_dialogic_signal(argument: String):
	# 4. Cek signal dari Dialogic untuk putar video kedua
	if argument == "play_video_2":
		play_intro_video("res://teamgamejam/Assets/Videos/INTRO LUNA 2.ogv")
