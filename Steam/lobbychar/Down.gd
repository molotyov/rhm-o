extends BaseStateLobby

var move_dir 

func _enter():
	host.apply_force("0", "3")



func _input_check():
	if Input.is_action_pressed("Crouch"):
		fallback_state = "Down"
	else:
		fallback_state = "Wait"
