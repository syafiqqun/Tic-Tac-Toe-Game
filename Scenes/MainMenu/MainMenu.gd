# main menu
extends Node2D

onready var change_scene = get_node("/root/ChangeScene")

func _on_StartGameButton_pressed() -> void:
	change_scene.change_to_play_scene()
	change_scene.set_mode_num(1)

func _on_Player_vs_AI_Button_pressed() -> void:
	change_scene.change_to_play_scene()
	change_scene.set_mode_num(2)

func _exit_tree() -> void:
	print("Deleted main menu")
