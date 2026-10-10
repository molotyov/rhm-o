extends Panel

class_name CharacterSelect

var singleplayer = true
var current_selected_character = 1
var char_buttons = []
signal match_ready(data)
var match_data
var selected_characters = {}

func _ready():
	for name in U.name_paths:
		var data = U.name_paths[name]
		var button = load(data[1]).instance()
		button.char_name = name
		button.initialize_name()
		$ScrollContainer/CenterContainer/GridContainer.add_child(button)
		char_buttons.append(button)
		button.connect("pressed", self, "_on_button_pressed", [button])
		button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
		var preview = button.get_child(1)
		preview.position = $PreviewContainer.rect_position
	$"%GoButton".disabled = true
	$"%GoButton".connect("pressed", self, "start")
	
func get_display_data(button):
	var data = {}
	var scene = button.character.instance()
	data["name"] = scene.char_name
	data["portrait"] = scene.character_portrait
	scene.free()
	return data


func _on_button_mouse_entered(button):
	for i in get_children():
		if i.is_in_group("copy"):
			i.queue_free()
			print("did it")

	var data = get_display_data(button)
	var prev = button.get_child(1)

	var copy = prev.duplicate()
	add_child(copy)
	copy.add_to_group("copy")
	copy.visible = true
	copy_preview_data(copy)
	
	u.fade_in(copy)


func copy_preview_data(copy):
	copy.position = Vector2(250, 250)
	copy.nudge_offset = Vector2.ZERO
	copy.base_position = Vector2(250, 250)
	copy.text_position = Vector2(0, 150)
	copy.position = copy.base_position


func _on_button_pressed(button):
	var data = get_display_data(button)
	display_character(current_selected_character, data)
	selected_characters[current_selected_character] = data

	if singleplayer and current_selected_character == 1:
		current_selected_character = 2
	else:
		for button in char_buttons:
			button.disabled = true
			button.get_node("Disabled").visible = true
			$"%SelectingLabel".hide()
		$"%GoButton".disabled = false
		$"%GoButton".show()
	pass

func display_character(id, data):
	var display = $"%P1" if id == 1 else $"%P2"
	display.load_character_data(data)

func start():
	print("eys2")
	if singleplayer:
		emit_signal("match_ready" ,get_match_data())


func get_match_data():
	var data = {
		"singleplayer": singleplayer, 
		"selected_characters": selected_characters, 
}
	return data
