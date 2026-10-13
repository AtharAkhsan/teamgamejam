extends Area2D

signal hit
signal lane_changed

var lane_positions: Array = [300.0, 430.0, 560.0]
var current_lane: int = 1
var target_y: float = 430.0
var is_invincible: bool = false
var is_active: bool = true
var invincible_timer: float = 0.0

const INVINCIBLE_DURATION := 1.5
const LANE_SWITCH_SPEED := 12.0


func _ready():
	target_y = lane_positions[current_lane]
	position.y = target_y
	scale = Vector2(2.0, 2.0)
	
	area_entered.connect(_on_area_entered)


func _process(delta: float):
	if is_active:
		if Input.is_action_just_pressed("up") and current_lane > 0:
			current_lane -= 1
			target_y = lane_positions[current_lane]
			lane_changed.emit()

		if Input.is_action_just_pressed("down") and current_lane < 2:
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
