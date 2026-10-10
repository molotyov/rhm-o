extends Node

class_name Main

var game
var match_data
var singleplayer

func _ready():
	$"%SteamLobbyList".connect("joined_lobby_success", self, "_on_created_lobby")

	$"%CharSelect".connect("match_ready", self, "_on_match_ready")

func _on_match_ready(data):
	match_data = data
	singleplayer = true if data["singleplayer"] else false
	setup_game(singleplayer, data)
	emit_signal("game_started")


func setup_game(singleplayer, data):

	call_deferred("setup_game_deferred", singleplayer, data)

func setup_game_deferred(singleplayer, data):
	game = preload("res://Game.tscn").instance()
	$Game.add_child(game)
	$CharSelect.hide()
	game.start_game(singleplayer, data)


func _on_created_lobby():

	$"%SteamLobby".show()
	$"%SteamLobbyList".hide()
