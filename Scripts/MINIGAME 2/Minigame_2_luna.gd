extends Area2D

signal hit
signal lane_changed

var lane_positions: Array = [300.0, 430.0, 560.0]
var current_lane: int = 1
var target_y: float = 430.0
var is_invincible: bool = false
var is_active: bool = true
var invincible_timer: float = 0.0
var base_scale: float = 1.0

const INVINCIBLE_DURATION := 1.5
const LANE_SWITCH_SPEED := 12.0
const SPRITE_TARGET_HEIGHT := 80.0


func _load_tex(path: String) -> ImageTexture:
	var abs_path = ProjectSettings.globalize_path(path)
	var file = FileAccess.open(abs_path, FileAccess.READ)
	if not file:
		return null
	var data = file.get_buffer(file.get_length())
	file.close()
	var img = Image.new()
	var err: int = ERR_FILE_CORRUPT
	if data.size() >= 2 and data[0] == 0xFF and data[1] == 0xD8:
		err = img.load_jpg_from_buffer(data)
	elif data.size() >= 4 and data[0] == 0x89 and data[1] == 0x50:
		err = img.load_png_from_buffer(data)
	elif data.size() >= 4 and data[0] == 0x52 and data[1] == 0x49:
		err = img.load_webp_from_buffer(data)
	if err != OK:
		return null
	return ImageTexture.create_from_image(img)


func _ready():
	target_y = lane_positions[current_lane]
	position.y = target_y
	scale = Vector2(2.0, 2.0)
	
	area_entered.connect(_on_area_entered)


func _process(delta: float):
	if is_active:
		if (Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up")) and current_lane > 0:
			current_lane -= 1
			target_y = lane_positions[current_lane]
			lane_changed.emit()

		if (Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down")) and current_lane < 2:
			current_lane += 1
			target_y = lane_positions[current_lane]
			lane_changed.emit()

	position.y = lerp(position.y, target_y, LANE_SWITCH_SPEED * delta)

	if is_invincible:
		invincible_timer -= delta
		visible = fmod(invincible_timer, 0.2) > 0.1
		if invincible_timer <= 0.0:
			is_invincible = false
			visible = true


func _on_area_entered(area: Area2D):
	if is_invincible:
		return
	if area.is_in_group("obstacles"):
		is_invincible = true
		invincible_timer = INVINCIBLE_DURATION
		hit.emit()
