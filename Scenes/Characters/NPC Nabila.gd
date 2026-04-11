extends CharacterBody2D

var is_chatting = false
var player_in_area = false
var has_spoken = false

func _ready() -> void:
	# Menghubungkan sinyal Dialogic
	Dialogic.signal_event.connect(DialogicSignal)
	# Sinyal ini penting agar script tahu kapan dialog benar-benar selesai
	Dialogic.timeline_ended.connect(_on_dialogic_finished)

func _process(_delta: float) -> void:
	if player_in_area:
		# Jika tombol interaksi ditekan DAN sedang tidak mengobrol
		if Input.is_action_just_pressed("interact") and not is_chatting: 
			run_dialogue("GreetNabila")
			
func run_dialogue(dialogue_string):
	is_chatting = true
	has_spoken = true
	Dialogic.start(dialogue_string)

# Fungsi yang dipanggil otomatis saat dialog Dialogic selesai
func _on_dialogic_finished():
	is_chatting = false
	has_spoken = false # Reset agar bisa mengobrol lagi dari awal
	print("Obrolan selesai, Nabila standby.")

func DialogicSignal(arg: String):
	# Kamu bisa pakai ini untuk event spesifik di tengah dialog
	if arg == "exit_nabila": 
		print("Sinyal exit diterima, tapi Nabila tetap di sini.")
		# queue_free() DIHAPUS agar Nabila tidak hilang

# Pastikan kedua fungsi di bawah ini sudah terhubung (Connect) di tab Node Area2D
func _on_chat_detection_body_entered(body):
	if body.name == "Player" or body is Player:
		player_in_area = true

func _on_chat_detection_body_exited(body):
	if body.name == "Player" or body is Player:
		player_in_area = false
