extends Node2D

const LEVEL_MUSIC := preload("res://teamgamejam/Assets/Audio/Songs/Main Loop.mp3")
const ARRIVAL_TIMELINE := "TibaDiSekolah"

func _ready() -> void:
	MusicManager.play_music(LEVEL_MUSIC)
	# Datang pertama kali: muncul dekat pagar (ArrivalSpawn), bukan di depan pintu gedung.
	# Posisi default Player di scene tetap dipakai saat keluar dari SchoolInside.
	if GameManager.arriving_at_school:
		GameManager.arriving_at_school = false
		$Player.global_position = $ArrivalSpawn.global_position
		_play_arrival_monologue()

func _play_arrival_monologue() -> void:
	# Tunggu fade masuk selesai dulu supaya dialog tidak muncul di balik layar hitam
	while SceneTransition.is_transitioning:
		await get_tree().process_frame
	Dialogic.start(ARRIVAL_TIMELINE)

func _on_inside_door_body_entered(body: Node2D) -> void:
	if body is Player:
		GameManager.coming_from_outside = true
		SceneTransition.change_scene("res://teamgamejam/Scenes/Levels/SchoolInside.tscn")
