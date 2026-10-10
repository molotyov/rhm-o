extends BaseStateLobby

var move_dir 

func _enter():
	host.apply_force("5", "0")




func _input_check():
	if Input.is_action_pressed("Forward"):
		fallback_state = "Move"
	else:
		fallback_state = "Wait"
