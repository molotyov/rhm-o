extends BaseStateO

func _enter():
	._enter()

func _process(delta):
	if host.get_pos().y >= 0:
		host.change_state("Landing")
