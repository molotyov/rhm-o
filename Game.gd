extends Node2D

var p1 = null
var p2 = null
var match_data = null
var p1_pos = Vector2(-40, 0)
var p2_pos = Vector2(40, 0)
func _ready():
	$GameCamera.make_current()


func start_game(singleplayer: bool, match_data: Dictionary):
	self.match_data = match_data
	if U.name_paths.has(match_data.selected_characters[1]["name"]):
		p1 = load(U.name_paths[match_data.selected_characters[1]["name"]][0]).instance()



	else :
		return false
	if U.name_paths.has(match_data.selected_characters[2]["name"]):
		p2 = load(U.name_paths[match_data.selected_characters[2]["name"]][0]).instance()


	else :
		return false

	$Characters.add_child(p1)
	$Characters.add_child(p2)
	p1.goonslime(1)
	p2.goonslime(2)
	p1.init()
	p2.init()
	p1.update_data()
	p2.update_data()
	p1.set_pos(-4000000, 0)
	p2.set_pos(4000000, 0)
	p2.set_facing("Left")


