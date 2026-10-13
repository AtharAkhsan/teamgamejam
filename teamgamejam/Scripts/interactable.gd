extends Area2D

# Objek yang bisa diinteraksi dengan tombol "interact" (E), misalnya rak buku.
# Butuh child: CollisionShape2D (area interaksi) dan InteractPrompt (interact_prompt.tscn).

## Timeline Dialogic yang diputar saat interaksi
@export var timeline := ""
## Kalau diisi: objek hanya bisa diinteraksi selama to-do ini aktif
@export var required_todo := ""
## Kalau diisi: to-do ini diselesaikan setelah timeline-nya selesai
@export var completes_todo := ""

var player_in_area := false
var is_running := false

@onready var prompt: Node2D = $InteractPrompt


func _ready() -> void:
	body_entered.connect(func(body): if body is Player: player_in_area = true)
	body_exited.connect(func(body): if body is Player: player_in_area = false)
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func _process(_delta: float) -> void:
	var can_interact := player_in_area and not is_running and Dialogic.current_timeline == null \
		and (required_todo == "" or QuestManager.is_active(required_todo))
	prompt.visible = can_interact
	if can_interact and Input.is_action_just_pressed("interact"):
		is_running = true
		Dialogic.start(timeline)


func _on_timeline_ended() -> void:
	if not is_running:
		return
	is_running = false
	if completes_todo != "":
		QuestManager.complete_todo(completes_todo)
