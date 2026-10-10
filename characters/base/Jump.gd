extends BaseStateO

func _enter():
	._enter()
	host.grounded = false   

func _frame_5():
	host.apply_force("2", "-5")

