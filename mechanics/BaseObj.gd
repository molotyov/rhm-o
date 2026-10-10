extends Node2D

class_name BaseObj

var can_update_sprite = true
var id
var initialized = false
var obj_data
var data
var spawn_data = null
var position_x: int
var position_y: int
var vel_x: String
var vel_y: String
export  var gravity: String = "0.8"
export  var ground_friction: String = "150"
export  var air_friction: String = "15"
export  var max_ground_speed: String = "1500"
export  var max_air_speed: String = "10"
export  var max_fall_speed: String = "15"
export var gravity_modifier: String = "1.0"
export (Texture) var character_portrait
var state_interruptable = true
var state_hit_cancellable = false



var facing = {
	"Left": -1,
	"Right": 1,
}

var fixed = FixedMath.new()

onready var collision_box = $CollisionBox
onready var hurtbox = $Hurtbox
onready var particles = $"%Particles"
onready var state_machine = $StateMachine
onready var sprite = $"%Sprite"

var hitboxes = []

var accel = FixedVec2.new()
var grounded = true
var pos = FixedVec2.new()
var vel = FixedVec2.new()


func init(pos = null):
	print("init")
	if id == 2:
		facing = "Left"
		sprite.flip_h = true
	elif id == 1:
		facing = "Right"
	state_machine.init("", spawn_data)


func goonslime(fighter):
	if fighter == 1:
		id = 1
	else:
		id = 2
		print(id)
	
func _ready():

	print(facing)
	state_machine.connect("state_exited", self, "_on_state_exited")
func set_positione(point: FixedVec2):
	pos.x = point.x
	pos.y = point.y
	position.x = float(pos.x) / FixedVec2.SCALE
	position.y = float(pos.y) / FixedVec2.SCALE


func move_directly(v: FixedVec2):
	set_positione(FixedVec2.new(pos.x + v.x, pos.y + v.y))
	

func apply_forces():
	vel.x += accel.x
	vel.y += accel.y

	if grounded:
		apply_grounded_fric()
	else:
		apply_aerial_fric()

	var vel_x_str = fixed.fixed_to_string(vel.x)
	var max_gs = fixed.from_string(max_ground_speed)
	var max_as = fixed.from_string(max_air_speed)

	if grounded:
		if int(fixed.abs(vel_x_str)) > max_gs:
			vel.x = max_gs * fixed.sign(vel_x_str)
	else:
		if int(fixed.abs(vel_x_str)) > max_as:
			vel.x = max_as * fixed.sign(vel_x_str)

	move_directly(vel)
	if grounded and vel.y > 0 and U.is_in_lobby == false:
		vel.y = 0
	accel = FixedVec2.new()

func ap_force(f: FixedVec2):
	if grounded and f.y > 0 and U.is_in_lobby == false:
		f.y *= 0
	accel.x += f.x
	accel.y += f.y

func apply_force(x, y):
	ap_force(FixedVec2.coords(x, y))

func apply_fric():
	if grounded:
		apply_grounded_fric()
	else:
		apply_aerial_fric()

func apply_grounded_fric():
	var vel_x_str = fixed.fixed_to_string(vel.x)
	var s = fixed.sign(vel_x_str)
	
	var friction = fixed.mul(
		fixed.abs(vel_x_str),
		fixed.div(ground_friction, max_ground_speed)
	)
	
	vel.x -= fixed.from_string(friction) * s
	
	if s > 0 and vel.x < 0:
		vel.x = 0
	elif s < 0 and vel.x > 0:
		vel.x = 0

func apply_aerial_fric():
	var vel_x_str = fixed.fixed_to_string(vel.x)
	var s = fixed.sign(vel_x_str)
	
	var friction = fixed.mul(
		fixed.abs(vel_x_str),
		fixed.div(air_friction, max_ground_speed)
	)
	
	vel.x -= fixed.from_string(friction) * s
	
	if s > 0 and vel.x < 0:
		vel.x = 0
	elif s < 0 and vel.x > 0:
		vel.x = 0





func apply_grav():
	if not grounded and vel.y < fixed.from_string(max_fall_speed):
		var grav = fixed.mul(gravity, gravity_modifier)
		apply_force("0.0", grav)




func change_state(state_name, state_data = null, enter = true, exit = true):
	state_machine._change_state(state_name, state_data, enter, exit)

func on_state_started(state):
	state_interruptable = false
	state_hit_cancellable = false
	pass

func on_state_ended(state):
	pass

func _on_state_exited(state):
	for hitbox in hitboxes:
		hitbox.deactivate_hitbox()

func current_state():
	return state_machine.state

func update_data():
	data = get_data()
#	obj_data = data["object_data"]
	if initialized:
		data["state_data"] = {
			"state": state_machine.state.state_name, 
			"frame": state_machine.state.current_tick, 
		}
	else :
		data["state_data"] = {
			"state": "", 
			"frame": 0, 
		}

func get_data():
	return {
		"position_x": fixed.round(fixed.fixed_to_string(pos.x)),
		"position_y": fixed.round(fixed.fixed_to_string(pos.y)),
		"vel_x": fixed.fixed_to_string(vel.x),
		"vel_y": fixed.fixed_to_string(vel.y),
		"grounded": grounded
	}

func previous_state():
	return current_state()._previous_state()

func get_facing_int():
	return - 1 if get_facing() == "Left" else 1

func get_facing():
	return facing

func set_facing(facing):
	match facing:
		-1: "Left"
		1: "Right"

func get_pos():
	return {
		"x": get_data().position_x, 
		"y": get_data().position_y
	}

static func fixed_vec2_string(x: String, y: String):
	return {
		"x": x, 
		"y": y, 
	}



func xy_to_dir(x, y, mul = "100", div = "100.0"):
	var unscaled_force = fixed.vec_div(str(x), str(y), div)
	var force = fixed.vec_mul(unscaled_force["x"], unscaled_force["y"], mul)
	return fixed_vec2_string(force.x,force.y)

func reset_momentum():
	vel = FixedVec2.new()
	accel = FixedVec2.new()

func turn_around():
	set_facing(get_facing_int() * - 1)

func set_pos(x, y):
	set_positione(FixedVec2.new(x, y))
