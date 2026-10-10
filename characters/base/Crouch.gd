extends BaseStateO



func _exit():
	._exit()
	host.can_input = true
	if Input.is_action_pressed("Crouch"):
		fallback_state = "Crouch" 
	else:
		 fallback_state == "Wait"
