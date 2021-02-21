#change scene
extends Node

var play_scene = preload("res://Scenes/PlayScene/PlayScene.tscn")
var main_menu = preload("res://Scenes/MainMenu/MainMenu.tscn")

var mode_num = 0

func set_mode_num(value):
	mode_num = value

func get_mode_num():
	return mode_num

func change_to_play_scene():
	get_tree().change_scene_to(play_scene)

func change_to_main_menu():
	get_tree().change_scene_to(main_menu)
