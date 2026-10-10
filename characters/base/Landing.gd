extends BaseStateO

func _enter():
	._enter()





func _input_check():

	if Input.is_action_pressed("Jump"):
		if Input.is_action_pressed("Forward"):
			fallback_state = "JumpForward"
		elif Input.is_action_pressed("Backward"):
			fallback_state = "JumpBackward"
		else:
			fallback_state = "Jump"

	elif Input.is_action_pressed("Forward"):
		fallback_state = "Move"
	elif Input.is_action_pressed("Backward"):
		fallback_state = "MoveBack"

	else:
		fallback_state = "Wait"
