extends BaseStateO

var move_dir 

func _enter():
	host.apply_force("-1", 0)

#
#func _exit():
#	if Input.is_action_pressed("Backward"):
#		fallback_state = "CrouchBackward"
#	else:
#		fallback_state = "Crouch" if Input.is_action_pressed("Crouch") else fallback_state == "Wait"
