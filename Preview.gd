extends AnimatedSprite

var nudge_amount = 0.005
var nudge_offset = Vector2.ZERO
var base_position = Vector2(246, 241)
var return_speed = 0.5
var text_position = Vector2(300, 241)

func _ready():
	base_position = position

func _input(event):
	if event is InputEventMouseMotion:
		nudge_offset += event.relative * nudge_amount

func _process(delta):
	nudge_offset = nudge_offset.linear_interpolate(Vector2.ZERO, return_speed * delta)
	position = base_position + nudge_offset
	

	for child in get_children():
		if child is Sprite:
			child.position = text_position - nudge_offset

