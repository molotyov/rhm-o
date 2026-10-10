extends BaseStateO

var move_dir 

func _enter():
	host.apply_force("1.5", "0")


#func _exit():
#	if Input.is_action_pressed("Forward"):
#		fallback_state = "CrouchForward"
#	else:
#		fallback_state = "Crouch" if Input.is_action_pressed("Crouch") else fallback_state == "Wait"
