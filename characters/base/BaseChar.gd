extends BaseObj

class_name BaseChar

var char_name = "Jup"
var can_input = true

func _ready():
	state_machine.init()
	sprite.animation = "Idle"
	print(id)

func _unhandled_input(event):
	var action = what_action_is_event(event)

	if action == null:
		return
	if can_input == true:
		if grounded == true and not current_state().state_name in JUMP_STATES:
			match action:
				"Forward":
					if Input.is_action_pressed("Jump"):
						change_state("JumpForward")
					if Input.is_action_pressed("Crouch"):
						change_state("CrouchForward")
					else:
						change_state("Move")
				"Backward":
					if Input.is_action_pressed("Jump"):
						change_state("JumpBackward")
					if Input.is_action_pressed("Crouch"):
						change_state("CrouchBackward")
					else:
						change_state("MoveBack")
				"Crouch":
					if Input.is_action_pressed("Forward"):
						change_state("CrouchForward")
					elif Input.is_action_pressed("Backward"):
						change_state("CrouchBackward")
					else:
						change_state("Crouch")
				"Jump":
					if Input.is_action_pressed("Forward"):
						change_state("JumpForward")
					elif Input.is_action_pressed("Backward"):
						change_state("JumpBackward")
					else:
						change_state("Jump")
				"test":
					change_state("5A")




const HOLD_FALLBACKS = {
	"Crouch":          ["Crouch",  "Crouch",          "Wait"],
	"Move":          ["Forward",  "Move",          "Wait"],
	"MoveBack":      ["Backward", "MoveBack",      "Wait"],
	"CrouchForward": ["Forward",  "CrouchForward", "Wait"],
	"CrouchBackward":["Backward", "CrouchBackward","Wait"],
}

const JUMP_STATES = [
	"Jump",
	"JumpForward",
	"JumpBackward",
]

const HOLD_JUMP_RESTARTS = [
	"Landing"
]

const LOW_FRICTION_STATES = ["Move", "MoveBack", "CrouchForward", "CrouchBackward"]

func _process(delta):
	if get_pos().y < 0:
		grounded = false
	else:
		grounded = true
		pos.y = 0

	$Label.text = current_state().state_name + "\n" + get_facing()
		
	var state = current_state()
	var sname = state.state_name

	ground_friction = "50" if sname in LOW_FRICTION_STATES else "250"
	if can_input == true:
		if sname in HOLD_FALLBACKS:
			var data = HOLD_FALLBACKS[sname]
			var action = data[0]
			if Input.is_action_pressed(action):
				state.fallback_state = data[1]
			elif Input.is_action_just_released(action):
				state.fallback_state = data[2]

#		if sname in HOLD_JUMP_RESTARTS:
#			if grounded:
#				if Input.is_action_just_pressed("Jump"):
#					if Input.is_action_pressed("Forward"):
#						state.fallback_state = "JumpForward"
#					elif Input.is_action_pressed("Backward"):
#						state.fallback_state = "JumpBackward"
#					else:
#						state.fallback_state = "Jump"
#				elif Input.is_action_just_released("Jump"):
#						state.fallback_state = "Wait"

func what_action_is_event(event):
	if id == 1:
		for action in InputMap.get_actions():
			if event.is_action_pressed(action):
				return action
		return null
