extends CharacterBody2D

# Alur quest Nabila:
#   1. GreetNabila  : obrolan gagal ("bakar apa?")  -> to-do "Belajar Bahasa Manusia"
#   2. (baca kamus di rak buku kelas, lihat interactable.gd di SchoolInside)
#   3. NabilaTeman  : obrolan berhasil              -> to-do "Mendapatkan Teman" selesai
#   4. NabilaSapa   : sapaan singkat setelah berteman
const QUEST_LANGUAGE := "Belajar Bahasa Manusia"
const QUEST_FRIEND := "Mendapatkan Teman"

var is_chatting = false
var player_in_area = false
# Diisi dari signal Dialogic, dijalankan setelah dialog tertutup supaya notifikasinya kelihatan
var pending_signal := ""

@onready var prompt: Node2D = $InteractPrompt

func _ready() -> void:
	# Menghubungkan sinyal Dialogic
	Dialogic.signal_event.connect(DialogicSignal)
	# Sinyal ini penting agar script tahu kapan dialog benar-benar selesai
	Dialogic.timeline_ended.connect(_on_dialogic_finished)

func _process(_delta: float) -> void:
	# Prompt "E" hanya muncul kalau player dekat dan tidak ada dialog yang sedang jalan
	var can_talk: bool = player_in_area and not is_chatting and Dialogic.current_timeline == null
	prompt.visible = can_talk
	if can_talk and Input.is_action_just_pressed("interact"):
		run_dialogue(_pick_timeline())

func _pick_timeline() -> String:
	if QuestManager.is_completed(QUEST_FRIEND):
		return "NabilaSapa"
	if QuestManager.is_completed(QUEST_LANGUAGE):
		return "NabilaTeman"
	return "GreetNabila"

func run_dialogue(dialogue_string):
	is_chatting = true
	Dialogic.start(dialogue_string)

# Fungsi yang dipanggil otomatis saat dialog Dialogic selesai
# (is_chatting di-reset agar bisa mengobrol lagi)
func _on_dialogic_finished():
	if not is_chatting:
		return
	is_chatting = false
	match pending_signal:
		"exit_nabila":
			QuestManager.add_todo(QUEST_LANGUAGE)
		"nabila_teman":
			QuestManager.complete_todo(QUEST_FRIEND)
	pending_signal = ""

func DialogicSignal(arg: String):
	# exit_nabila  = akhir GreetNabila (Lulu sadar harus belajar bahasa manusia)
	# nabila_teman = akhir NabilaTeman (berhasil berteman)
	if is_chatting and arg in ["exit_nabila", "nabila_teman"]:
		pending_signal = arg

# Dihubungkan dari signal chatDetection (body_entered / body_exited) di npc_nabila.tscn
func _on_chat_detection_body_entered(body):
	if body is Player:
		player_in_area = true

func _on_chat_detection_body_exited(body):
	if body is Player:
		player_in_area = false
