class_name Hartono extends CharacterBody2D

# TODO: NPC ini belum bisa diajak bicara. Yang masih kurang:
#   - Area2D "chatDetection" di npc_botak.tscn (lihat npc_nabila.tscn) yang
#     di-connect ke _on_chat_detection_body_entered / _on_chat_detection_body_exited
#   - Timeline Dialogic "greetHartono" (+ karakter Hartono di Dialogic/Characters)

var is_chatting = false

var player_in_area = false
var has_spoken = false

func _ready() -> void:
		Dialogic.signal_event.connect(DialogicSignal)

func _process(_delta: float) -> void:
	if player_in_area:
		if Input.is_action_just_pressed("interact") and not is_chatting and not has_spoken:
			run_dialogue("greetHartono")

func run_dialogue(dialogue_string):
	QuestManager.complete_todo("bicara_hartono")
	is_chatting = true
	has_spoken = true
	Dialogic.start(dialogue_string)

func DialogicSignal(arg: String):
	if arg == "exit_hartono":
		queue_free()

func _on_chat_detection_body_entered(body):
	if body is Player:
		player_in_area = true

func _on_chat_detection_body_exited(body):
	if body is Player:
		player_in_area = false
