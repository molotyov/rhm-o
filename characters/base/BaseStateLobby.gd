extends StateInterface

class_name BaseStateLobby

signal state_started()
signal state_ended()

export  var _c_Physics = 0
export  var apply_forces = false
export  var apply_fric = false
export  var apply_grav = false
export  var reset_momentum = false
export  var reset_x_momentum = false
export  var reset_y_momentum = false

export  var _c_Custom_Physics = 0
export  var apply_custom_x_fric = false
export  var apply_custom_y_fric = false
export  var apply_custom_grav = false
export  var apply_forces_no_limit = false

export  var custom_x_fric = "0.0"
export  var custom_y_fric = "0.0"
export  var custom_grav = "0.0"
export  var custom_grav_max_fall_speed = "0.0"

export  var apply_custom_limits = false

export  var custom_max_air_speed = "15.0"
export  var custom_max_ground_speed = "10.0"


export  var _c_Animation_and_Length = 0
export  var fallback_state = "Wait"
export  var sprite_animation = ""
export  var anim_length = 1
export  var sprite_anim_length = - 1
export  var ticks_per_frame = 1
export  var loop_animation = false
export  var animation_loop_start = 0
export  var absolute_loop = false
export  var refresh_loop = true
export  var endless = false
export  var disable_at_end = false

export  var _c_Static_Force = 0
export  var force_dir_x = "0.0"
export  var force_dir_y = "0.0"
export  var force_speed = "0.0"
export  var force_tick = 0

export  var _c_Enter_Static_Force = 0
export  var enter_force_dir_x = "0.0"
export  var enter_force_dir_y = "0.0"
export  var enter_force_speed = "0.0"

export  var _c_Iasa_At = 0
export var can_input = false
export var recover_at = -1

export  var _c_Particles = 0
export (PackedScene) var particle_scene = null
export  var particle_position = Vector2()
export  var spawn_particle_on_enter = false

export  var _c_Screenshake = 0
export  var state_screenshake_tick = - 1
export  var state_screenshake_dir = Vector2()
export  var state_screenshake_length = 0.25
export  var state_screenshake_amount = 10

export  var _c_TimedParticles = 0
export (PackedScene) var timed_particle_scene = null
export  var timed_particle_position = Vector2()
export  var timed_spawn_particle_tick = 1

export  var _c_Sfx = 0
export (AudioStream) var enter_sfx = null
export  var enter_sfx_volume = - 15.0
export (AudioStream) var sfx = null
export  var sfx_tick = 1
export  var sfx_volume = - 15.0

export  var _c_Projectiles = 0
export (PackedScene) var projectile_scene
export  var projectile_tick = 1
export  var projectile_pos_x = 0
export  var projectile_pos_y = 0
export  var projectile_local_pos = true
export  var projectile_match_facing = false

export  var _c_Other = 0
export  var extra_parry_hitlag = 0


export  var _c_Flip = 0
export  var flip_frame = - 1
export  var force_same_direction_as_previous_state = false

var enter_sfx_player
var sfx_player
var has_exited = false
var is_grab = false
var current_tick = - 1
var current_real_tick = - 1
var start_tick = - 1
var last_facing = 1
var fixed
var native

var anim_name
var property_list: PoolStringArray

var has_hitboxes = false

var current_hurtbox = null
var same_as_last_state = false

var host_command_nodes = {
	
}

var hitbox_start_frames = {
}

var hurtbox_state_change_frames = {
	
}

var limb_hurtboxes = []

var all_hitbox_nodes = []
var frame_methods = []
var frame_methods_shared = []
var max_tick = - 1
var max_tick_shared = - 1
var exit_tick = - 1






func _input_check():
	pass  

func _tick_before():
	pass

func process_feint():
	return fallback_state


func _process(delta):
	
	


	current_real_tick += 1
	
	if recover_at == -1:
		recover_at = anim_length
	elif current_tick != recover_at:
		if can_input == false:
			host.can_input = false
	
	if current_tick == recover_at:
		host.can_input = true

	if not endless and current_tick >= anim_length:
		if not has_exited:
			_exit_shared()
		return                  # ✅ stop processing after state ends

	current_tick += 1

	if host.can_update_sprite:
		update_sprite_frame()
#		if current_tick == sfx_tick and sfx_player and not ReplayManager.resimulating:
#			sfx_player.play()




	if current_tick == state_screenshake_tick:
		host.screen_bump(state_screenshake_dir, state_screenshake_amount, state_screenshake_length)

	if current_tick == flip_frame:
		host.turn_around()

#		if current_tick in host_commands:
#			var command = host_commands[current_tick]
#			if command is Array:
#				if not command.empty():
#					host.callv(command[0], command.slice(1, command.size() - 1))
#			elif command is String:
#				host.call(command)
#
#		if current_tick in host_command_nodes:
#			var commands = host_command_nodes[current_tick]
#			for command in commands:
#				host.callv(command.command, command.args)

		
		
	if current_tick in frame_methods_shared:
		var method_name = "_frame_" + str(current_tick) + "_shared"
			
		if has_method(method_name):
			if not (current_tick in frame_methods_shared):
				frame_methods_shared.append(current_tick)
			var next_state = call(method_name)
			if next_state != null:
				return next_state
			
	if has_method("_frame_" + str(current_tick)):
		var next_state = call("_frame_" + str(current_tick))
		if next_state != null:
			queue_state_change(next_state)


	if apply_fric:
		host.apply_fric()
	if apply_grav:
		host.apply_grav()
	if apply_forces:
		if apply_forces_no_limit:
			host.apply_forces_no_limit()
		
		elif apply_custom_limits:
			if host.is_grounded():
				host.limit_x_speed(custom_max_ground_speed)
			else :
				host.limit_x_speed(custom_max_air_speed)
			host.apply_forces_no_limit()
		else :
			host.apply_forces()

	if not endless and current_tick >= anim_length:
		if not has_exited:
			_exit_shared()



func _exit_shared():
	if has_exited:
		return
	has_exited = true
	exit_tick = current_tick
	
	_input_check()
	
	if host.state_machine.queued_states.empty():
		if fallback_state:
			host.change_state(fallback_state)
	emit_signal("state_ended")



#


func init():
	connect("state_started", host, "on_state_started", [self])
	connect("state_ended", host, "on_state_ended", [self])
	fixed = host.fixed
	anim_name = sprite_animation if sprite_animation else state_name
	if sprite_anim_length < 0:
		if host.sprite.frames.has_animation(anim_name):
			sprite_anim_length = host.sprite.frames.get_frame_count(anim_name)
		else :
			sprite_anim_length = anim_length


func _enter_shared():
	has_exited = false
	current_tick = 0
	same_as_last_state = false
	exit_tick = -1
	var prev = _previous_state()
	if prev and prev == self:
		same_as_last_state = true
	if force_same_direction_as_previous_state and prev:
		host.set_facing(prev.last_facing)
	if reset_momentum:
		host.reset_momentum()
	if reset_x_momentum:
		var vel = host.get_vel()
		host.set_vel("0", vel.y)
	if reset_y_momentum:
		var vel = host.get_vel()
		host.set_vel(vel.x, "0")

	emit_signal("state_started")

func xy_to_dir(x, y, mul = "1.0", div = "100.0"):
	return host.xy_to_dir(x, y, mul, div)


func update_sprite_frame():
	if not host.sprite.frames.has_animation(anim_name):
		return 
	if host.sprite.animation != anim_name:
		host.sprite.animation = anim_name
		host.sprite.frame = 0
	var sprite_tick = current_tick / ticks_per_frame

	if loop_animation and absolute_loop:
		sprite_tick = host.current_tick / ticks_per_frame
	elif loop_animation and not refresh_loop:
		if same_as_last_state:
			sprite_tick = (current_tick + exit_tick) / ticks_per_frame

		
	var frame = (sprite_tick % (sprite_anim_length - animation_loop_start) + animation_loop_start) if (loop_animation and sprite_tick > animation_loop_start) else u.int_min(sprite_tick, sprite_anim_length)
	host.sprite.frame = frame

