extends BaseStateO

var move_dir 

func _enter():
	host.apply_force("2.5", "0")

#func _frame_5():
#	host.apply_force(60000, 0)


func _exit():
	# if still holding forward when state ends, loop back
	if Input.is_action_pressed("Forward"):
		fallback_state = "Move"
	else:
		fallback_state = "Wait"  # your default fallback

func _input_check():
	if Input.is_action_pressed("Forward"):
		fallback_state = "Move"
	else:
		fallback_state = "Wait"
