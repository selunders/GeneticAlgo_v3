extends Node

var num_registered_players = 0

var player_controls: = [preload("res://resources/p1_controls.tres"), preload("res://resources/p2_controls.tres")]
var tagged_visual_scene = preload("res://scenes/tagged_indicator.tscn")

func _ready():
	Events.player_awake.connect(connect_player)

func connect_player(player):
	if not player:
		print("Error: No player passed in")
		return
	else:
		player.player_number = num_registered_players + 1
		player.set_controls(player_controls[num_registered_players])
		num_registered_players += 1
		if player.player_number == 1:
			player.tagged()
