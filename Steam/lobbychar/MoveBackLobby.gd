extends BaseStateLobby

var move_dir 

func _enter():
	host.apply_force("-5", "0")
	host.sprite.flip_h = true


func _input_check():
	host.sprite.flip_h = false
	if Input.is_action_pressed("Backward"):
		fallback_state = "MoveBack"
	else:
		fallback_state = "Wait"
