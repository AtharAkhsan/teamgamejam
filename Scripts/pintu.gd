extends StaticBody2D

@onready var anim = $AnimatedSprite2D
@onready var solid_collision = $CollisionShape2D

func _ready():
	# Memastikan pintu tertutup saat game baru mulai
	anim.play("tutup")

# Dihubungkan dari signal Area2D -> body_entered
func _on_area_2d_body_entered(body):
	if body is Player:
		buka_pintu()

# Dihubungkan dari signal Area2D -> body_exited
func _on_area_2d_body_exited(body):
	if body is Player:
		tutup_pintu()

# --- FUNGSI TERPISAH AGAR LEBIH RAPI ---

func buka_pintu():
	anim.play("buka")
	# Matikan collision penghalang agar bisa lewat
	solid_collision.set_deferred("disabled", true)

func tutup_pintu():
	anim.play("tutup")
	# Nyalakan lagi collision penghalang
	solid_collision.set_deferred("disabled", false)
