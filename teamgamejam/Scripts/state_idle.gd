class_name State_Idle extends State

@onready var walk : State = $"../Walk"

# Yang terjadi ketika Player memasuki "state" ini:
func Enter() -> void:
	player.UpdateAnimation("idle")
	pass
	
# Yang terjadi ketika Player keluar dari "state" ini:
func Exit() -> void:
	pass
	
func Process( _delta : float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	return null
	
func Physics ( _delta : float ) -> State:
	return null
	
func HandleInput ( _event : InputEvent ) -> State:
	return null
