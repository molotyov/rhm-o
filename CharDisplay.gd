extends Control


func load_character_data(data):
	$"%Portrait".texture = data["portrait"]
	$"%Name".text = data["name"]
