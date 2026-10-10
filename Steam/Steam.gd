extends Node



func _ready() -> void:
	steam()
	
func steam():
	var response: Dictionary = Steam.steamInit()

func _process(delta):
	Steam.run_callbacks()




