extends CharacterBody2D

var is_chatting = false
var player_in_area = false

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
	Dialogic.start(dialogue_string)

# Fungsi yang dipanggil otomatis saat dialog Dialogic selesai
# (is_chatting di-reset agar bisa mengobrol lagi dari awal)
func _on_dialogic_finished():
	is_chatting = false

func DialogicSignal(arg: String):
	# Kamu bisa pakai ini untuk event spesifik di tengah dialog
	if arg == "exit_nabila":
		pass # Nabila tetap di sini (tidak di-queue_free)

# Dihubungkan dari signal chatDetection (body_entered / body_exited) di npc_nabila.tscn
func _on_chat_detection_body_entered(body):
	if body is Player:
		player_in_area = true

func _on_chat_detection_body_exited(body):
	if body is Player:
		player_in_area = false
