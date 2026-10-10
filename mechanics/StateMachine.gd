extends Node

class_name StateMachine

const STACK_SIZE = 32

var states_stack = []
var states_map = {}
var state
var queued_states = []
var queued_data = []

var initialized = false

signal state_changed(states_stack)
signal state_exited(state)

export  var starting_state: String = ""
export  var host_node_path: NodePath



export  var animation_player_path: NodePath
export  var animated_sprite_path: NodePath

var animated_sprite
var animation_player

var is_ready = false
var host












func _ready():
	is_ready = true

func _enter_tree():
	var custom_host = get_node_or_null(host_node_path)
	if not is_instance_valid(custom_host):
		host = get_parent()
	else :
		host = custom_host



#==Constants==
#MAX_ROLLBACK_FRAMES     := Any Positive Integer         # Specifies the maximum number of frames that can be resimulated
#FRAME_ADVANTAGE_LIMIT   := Any Positive Integer         # Specifies the number of frames the local client can progress ahead of the remote client before time synchronizing. 
#INITAL_FRAME            := Any Integer                  # Specifies the initial frame the game starts in. Cannot rollback before this frame.
#
#[Initialize Variables]
#    local_frame   := INITAL_FRAME                       # Tracks the latest updates frame. 
#    remote_frame  := INITAL_FRAME                       # Tracks the latest frame received from the remote client
#    sync_frame    := INITAL_FRAME                       # Tracks the last frame where we synchronized the game state with the remote client. Never rollback before this frame.
#    remote_frame_advantage := 0                         # Latest frame advantage received from the remote client.
#
#[Store Game State]
#    Stores the game state for the current frame 
#
#[Restore Game State]
#    Restores the game state to the frame set in sync_frame
#
#[Update Input]
#    Predict the remote player's input if not available yet.
#    Setup the local player and remote player's input for use in [Update Game] 
#
#[Rollback Condition]
#    local_frame > sync_frame AND remote_frame > sync_frame      # No need to rollback if we don't have a frame after the previous sync frame to synchronize to.
#
#[Time Synced]
#    Let local_frame_advantage = local_frame - remote_frame                                   # How far the client is ahead of the last reported frame by the remote client
#    Let frame_advantage_difference = local_frame_advantage - remote_frame_advantage          # How different is the frame advantage reported by the remote client and this one.
#    local_frame_advantage < MAX_ROLLBACK_FRAMES AND frame_advantage_difference <= FRAME_ADVANTAGE_LIMIT     # Only allow the local client to get so far ahead of remote.
#
#Start Program:
#    [Initialize Variables]
#
#    loop:
#
#    [Update Network]
#        Let remote_frame = latest frame received from the remote client
#        Let remote_frame_advantage = (local_frame - remote_frame) sent from the remote client
#
#    [Update Synchronization]
#        [Determine the sync_frame]
#            Let final_frame = remote_frame                                          # We will only check inputs until the remote_frame, since we don't have inputs after.
#            if remote_frame > local_frame then final_frame = local_frame           # Incase the remote client is ahead of local, don't check past the local frame.
#            select frames from (sync_frame + 1) through final_frame and find the first frame where predicted and remote inputs don't match
#                if found then
#                    sync_frame = found frame - 1        # The found frame is the first frame where inputs don't match, so assume the previous frame is synchronized.
#                else
#                    sync_frame = final_frame            # All remote inputs matched the predicted inputs since the last synchronized frame.
#
#        if [Rollback Condition] then
#            [Execute Rollbacks]
#                [Restore Game State]
#                select inputs from (sync_frame + 1) through local_frame     # Use all the inputs since the last sync frame until the current frame to simulate
#                    [Rollback Update]
#                        [Update Input]
#                        [Update Game]
#                        [Store Game State]
#
#    if [Time Synced] then
#        [Normal Update]
#            Increment local_frame
#            [Get Local Player Input]
#                Read the joystick/pad/keyboard for the local player and store it, associating it with local_frame
#            [Send input to remote client]
#                Send the input and the local_frame to the remote client so it arrives asap.
#
#            [Update Input]
#            [Update Game]
#            [Store Game State]
#    goto loop
#
#End Program



















func init(st: String = "", data = null)->bool:
	if not is_ready:
		yield (self, "ready")
	if initialized:
		return 
	if starting_state:
		st = starting_state
	var can_initialize = false
	var states_array = get_children()
	if states_array == []:
		queue_free()
		return false
	for new_state in states_array:
		if new_state is StateInterface:
			states_map[new_state.get_name()] = new_state
			can_initialize = true
			new_state.connect("queue_change", self, "queue_state")
			new_state.connect("queue_change_with_data", self, "queue_state")
			new_state.host = host
			new_state.init()
		else :
			new_state.queue_free()
			states_array.erase(new_state)
	if not can_initialize:
		queue_free()
		return false
		
	animated_sprite = weakref(get_node_or_null(animated_sprite_path))
	animation_player = weakref(get_node_or_null(animation_player_path))
	
	var a = self.animation_player.get_ref()
	if a != null:
		a.connect("animation_finished", self, "auto_transition")

	if st != "":
		_change_state(states_map[st].get_name(), data)
	else :
		_change_state(states_array[0].get_name(), data)
	initialized = true
	return true

func auto_transition(_anim_name):
	var next = state._animation_finished()
	if next:
		queue_state(next)

func queue_state(new_state, data = null, old_state = state):
	if old_state.active:
		queued_states = []
		queued_data = []
		queued_states.push_back(new_state)
		queued_data.append(data)

func update(delta):
	if queued_states.size() > 0:
		var state = queued_states.pop_front()
		var data = queued_data.pop_front()
		_change_state(state, data)
	var next_state_name = state._update_shared(delta)
	if next_state_name == null:
		next_state_name = state._update(delta)
	if next_state_name:
		queue_state(next_state_name)

func _process(delta):
	if queued_states.size() > 0:
		var state = queued_states.pop_front()
		var data = queued_data.pop_front()
		_change_state(state, data)

func deactivate():
	state.active = false
	state._exit_shared()
	state._exit()
	emit_signal("state_exited", state)

func integrate(st):
	state._integrate_shared(st)
	state._integrate(st)

func _change_state(state_name: String, data = null, enter = true, exit = true)->void :
	assert (states_map.has(state_name), "you tried to enter a state that doesn't exist, CHUMP")
	if not states_map.has(state_name):
		return 
	var next_state = states_map[state_name]
	queued_states = []
	queued_data = []

	if state:
		if exit:
			state._exit_shared()
			state._exit()
			emit_signal("state_exited", state)
		state.active = false
		state.set_physics_process(false)
		state.set_process(false)

	state = next_state
	states_stack.push_back(state)
	if states_stack.size() > STACK_SIZE:
		states_stack.pop_front()
	state.active = true
	state.set_physics_process(true)
	state.set_process(true)

	











	state.data = data

	if enter:
		var new_state = state._enter_shared()
		if new_state:
			_change_state(new_state)
			return 
		new_state = state._enter()
		if new_state:
			_change_state(new_state)
			return 
	
	emit_signal("state_changed", states_stack)

func try(method: String, args: Array = []):
	if state.has_method(method):
		state.callv(method, args)

func last_x_states(x, names = true):
	var states = states_stack.slice( - x, states_stack.size())
	if names:
		var s = []
		for state in states:
			s.append(state.name)
		states = s
	states.reverse()
	return states

func get_state(state_name):
	if states_map.has(state_name):
		return states_map[state_name]
