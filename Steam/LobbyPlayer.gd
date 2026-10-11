extends Panel

signal avatar_loaded()
var text 
var avatar 
var member

func init():
	if member.steam_id == 76561199249611563:
		$UserLabel.modulate = "ff0000"
		$UserLabel2.visible = true
	$UserLabel.text = text

func _ready():
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")

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
