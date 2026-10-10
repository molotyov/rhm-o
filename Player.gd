extends BaseObj



var member

var player_data: Dictionary = {
}


func _ready():
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")
	state_machine.init()
	sprite.animation = "Idle"

func _loaded_Avatar(id: int, size: int, buffer: PoolByteArray)->void :
	if id != member.steam_id:
		return 
	var AVATAR = Image.new()
	var AVATAR_TEXTURE: ImageTexture = ImageTexture.new()
	AVATAR.create_from_data(size, size, false, Image.FORMAT_RGBA8, buffer)
	
	AVATAR_TEXTURE.create_from_image(AVATAR)
	
	$"%Avatar".set_texture(AVATAR_TEXTURE)
	emit_signal("avatar_loaded")
	

func update_avatar():
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM, member["steam_id"])


var can_input = true

func get_data():
	return {
		"position_x": fixed.round(fixed.fixed_to_string(pos.x)),
		"position_y": fixed.round(fixed.fixed_to_string(pos.y)),

	}

func _unhandled_input(event):
	print()
	var action = what_action_is_event(event)

	if action == null:
		return

	if member.steam_id == Steam.getSteamID():
		match action:
			"Forward":
				change_state("Move")
			"Backward":
				change_state("MoveBack")
			"Crouch":
					change_state("Down")
			"Jump":
				change_state("Up")

func what_action_is_event(event):
	for action in InputMap.get_actions():
		if event.is_action_pressed(action):
			return action
	return null
