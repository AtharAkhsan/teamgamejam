class_name State extends Node

static var player : Player

func _ready() -> void:
	pass

# Yang terjadi ketika Player memasuki "state" ini:
func Enter() -> void:
	pass
	
# Yang terjadi ketika Player keluar dari "state" ini:
func Exit() -> void:
	pass
	
func Process( _delta : float ) -> State:
	return null
	
func Physics ( _delta : float ) -> State:
	return null
	
func HandleInput ( _event : InputEvent ) -> State:
	return null
