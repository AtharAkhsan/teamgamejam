extends Node

const MENU_MUSIC := preload("res://teamgamejam/Assets/Audio/Songs/Main menu.mp3")

@onready var music_player: AudioStreamPlayer = $AudioStreamPlayer

func play_menu_music():
	play_music(MENU_MUSIC)

# Mainkan lagu secara loop. Kalau lagu yang sama sudah jalan, biarkan (tidak restart)
func play_music(stream: AudioStream):
	if music_player.stream == stream and music_player.playing:
		return
	if stream is AudioStreamMP3:
		stream.loop = true
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
