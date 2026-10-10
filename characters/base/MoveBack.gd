extends BaseStateO

var move_dir 

func _enter():
	host.apply_force("-1", "0")



func _input_check():
	if Input.is_action_pressed("Backward"):
		fallback_state = "MoveBack"
	else:
		fallback_state = "Wait"
