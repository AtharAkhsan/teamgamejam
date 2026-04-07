extends Node

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

func play_menu_music():
	# Kita panggil si anak untuk mainkan musik
	if not music_player.playing:
		music_player.play()

func stop_music():
	music_player.stop()
