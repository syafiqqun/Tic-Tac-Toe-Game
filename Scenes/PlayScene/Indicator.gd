extends Node

func _ready() -> void:
	get_node("Player1_Off").hide()

func player_1_turn():
	print("player 1 turn")
	get_node("Player1_Off").hide()
	get_node("Player2_Off").show()

func player_2_turn():
	print("player 2 turn")
	get_node("Player1_Off").show()
	get_node("Player2_Off").hide()
