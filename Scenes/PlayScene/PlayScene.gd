# Made by Syafiq
# @Tutor Tomato
#---------------------------------------------------------------
# play scene
extends Node2D

onready var change_scene_singleton = get_node("/root/ChangeScene")
onready var sound_player = get_node("sounds/game_over_fx")
onready var player_1_sound = get_node("sounds/player_1_fx")
onready var player_2_sound = get_node("sounds/player_2_fx")

var cross_sprite = preload("res://Scenes/CrossSprite.tscn")
var circle_sprite = preload("res://Scenes/CircleSprite.tscn")
var sprite_pos = Vector2(0, 0)

var has_play_game_over_audio = false
var sounds_end = false

enum{PlayerMode = 1, AIMode = 2}
var mode_type = 0

enum {GameStart = 1, GameOver = 2}
var game_state = 0

enum {Empty = 0, Cross = 1, Circle = 2}

var grid_state = [0,0,0,
				  0,0,0,
				  0,0,0]

var current_grid_select = "empty"

#--------- gui state control ---------
var mouse_over_board = false
var can_reload = false
var overlay = false

#----------- player variable ---------
var current_player_turn = 1
var player_1_turn_num = [1, 3, 5, 7, 9]
var player_2_turn_num = [2, 4, 6, 8]

var player_won = "None"

func _ready() -> void:
	print("Game Start")
	mode_type = change_scene_singleton.get_mode_num()
	game_state = GameStart

func _exit_tree() -> void:
	print("Deleted play scene")

func _process(delta: float) -> void:
	# Game state checking
	if game_state == GameStart:
		# check game type
		if mode_type == PlayerMode:
			# accept input
			if Input.is_action_just_pressed("LeftClickMouse") and mouse_over_board == true:
				print("Draw")
				# update the board state and the data
				draw_pattern_on_board()
				update_indicator_current_player_turn()
				play_player_sounds_fx()
				
				print(current_player_turn)
				# check wether any player win the match
				winning_state()
				
			# check if the game is over when all turn are used up by the player
			if current_player_turn == 10:
				game_state = GameOver
				print("Game Over")
				
	# check if game is over show the "Game Over" overlay
	show_overlay_game_over()
	# play sounds
	play_sounds_fx()
	
	# reload game, the play scene to start over // simple reset
	if Input.is_action_just_pressed("ui_accept") and game_state == GameOver and can_reload == true:
		get_tree().reload_current_scene()

#=====================================================================
#		#----------------------------------------------------
#		# WIP code section
#		# abandoned,there will be no ai mode :)
		# but someday maybe,so I will leave this code section
#		if mode_type == AIMode:
#		
#			if Input.is_action_just_pressed("LeftClickMouse") and mouse_over_board == true and current_player_turn == 1:
#				print("Draw")
#				draw_pattern_on_board()
#				update_indicator_current_player_turn()
#				print(current_player_turn)
#			if current_player_turn != 1:
#				pass
#				# run min max algorithm and 
#		#----------------------------------------------------
#======================================================================

#--------- animation and sounds and button ----------------

func play_sounds_fx():
	if game_state == GameOver and has_play_game_over_audio == false:
		sound_player.play()
		has_play_game_over_audio = true

func play_player_sounds_fx():
	for s in player_1_turn_num:
		if current_player_turn == s:
			player_1_sound.play()
	for s in player_2_turn_num:
		if current_player_turn == s:
			player_2_sound.play()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if player_won == "Player1":
		get_node("GameOverOverlay/Player1Won").show()
		get_node("GameOverOverlay/GameOverText").show()
		get_node("GameOverOverlay/PlayAgainText").show()
		get_node("GameOverOverlay/AnimationPlayer").play("Blick_Text_Play_Again")
		can_reload = true
	if player_won == "Player2":
		get_node("GameOverOverlay/Player2Won").show()
		get_node("GameOverOverlay/GameOverText").show()
		get_node("GameOverOverlay/PlayAgainText").show()
		get_node("GameOverOverlay/AnimationPlayer").play("Blick_Text_Play_Again")
		can_reload = true
	if player_won == "None":
		get_node("GameOverOverlay/DrawText").show()
		get_node("GameOverOverlay/GameOverText").show()
		get_node("GameOverOverlay/PlayAgainText").show()
		get_node("GameOverOverlay/AnimationPlayer").play("Blick_Text_Play_Again")
		can_reload = true

func _on_MenuButton_pressed() -> void:
	get_node("/root/ChangeScene").change_to_main_menu()

#--------- update state and show functions ------------

func update_indicator_current_player_turn():
	for x in player_1_turn_num:
		if x == current_player_turn:
			get_node("Indicator").player_1_turn()
	for y in player_2_turn_num:
		if y == current_player_turn:
			get_node("Indicator").player_2_turn()

func update_current_player_turn():
	current_player_turn += 1

func show_overlay_game_over():
	if game_state == GameOver and overlay == false:
		if player_won == "Player1":
			get_node("GameOverOverlay/AnimationPlayer").play("Fade_In")
			overlay = true
		if player_won == "Player2":
			get_node("GameOverOverlay/AnimationPlayer").play("Fade_In")
			overlay = true
		if player_won == "None":
			get_node("GameOverOverlay/AnimationPlayer").play("Fade_In")
			overlay = true

#------- set and utillity functions -----------

func set_win_indicator(rotate_p, pos_x, pos_y):
		get_node("WinIndicator").position = Vector2(pos_x, pos_y)
		get_node("WinIndicator").rotation = deg2rad(rotate_p)
		get_node("WinIndicator").show()

func instance_scene(sprite_p, pos_x, pos_y):
	var sprite = sprite_p.instance()
	sprite.position = Vector2(pos_x, pos_y)
	get_node("PatternXO").add_child(sprite)

func draw_circle_or_cross(grid_state_p):
	for curr_player in player_1_turn_num:
		if curr_player == current_player_turn:
			print("Draw Cross")
			instance_scene(cross_sprite,sprite_pos.x, sprite_pos.y)
			grid_state[grid_state_p] = Cross
	for curr_player in player_2_turn_num:
		if curr_player == current_player_turn:
			print("Draw_Circle")
			instance_scene(circle_sprite,sprite_pos.x, sprite_pos.y)
			grid_state[grid_state_p] = Circle

func draw_on_grid(grid_select, grid_num):
	if current_grid_select == "g" + str(grid_select) and grid_state[grid_num] == Empty:
		draw_circle_or_cross(grid_num)
		update_current_player_turn()

func draw_pattern_on_board():
	draw_on_grid(1, 0)
	draw_on_grid(2, 1)
	draw_on_grid(3, 2)
	draw_on_grid(4, 3)
	draw_on_grid(5, 4)
	draw_on_grid(6, 5)
	draw_on_grid(7, 6)
	draw_on_grid(8, 7)
	draw_on_grid(9, 8)

#--------- check winning state function ------------ 

func winning_state():
	# player 1 win state horizontal
	if grid_state[0] == 1 and grid_state[1] == 1 and grid_state[2] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(90, 840, 210)
	if grid_state[3] == 1 and grid_state[4] == 1 and grid_state[5] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(90, 840, 450)
	if grid_state[6] == 1 and grid_state[7] == 1 and grid_state[8] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(90, 840, 690)
		
	# player 1 win state vertical
	if grid_state[0] == 1 and grid_state[3] == 1 and grid_state[6] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(0, 610, 450)
	if grid_state[1] == 1 and grid_state[4] == 1 and grid_state[7] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(0, 840, 450)
	if grid_state[2] == 1 and grid_state[5] == 1 and grid_state[8] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(0, 1060, 450)
	
	# player 1 win state diagonal
	if grid_state[0] == 1 and grid_state[4] == 1 and grid_state[8] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(-45, 840, 450)
	if grid_state[2] == 1 and grid_state[4] == 1 and grid_state[6] == 1:
		player_won = "Player1"
		game_state = GameOver
		print("Player 1 Won")
		set_win_indicator(45, 840, 450)
		
	# player 2 win state horizontal
	if grid_state[0] == 2 and grid_state[1] == 2 and grid_state[2] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(90, 840, 210)
	if grid_state[3] == 2 and grid_state[4] == 2 and grid_state[5] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(90, 840, 450)
	if grid_state[6] == 2 and grid_state[7] == 2 and grid_state[8] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(90, 840, 690)
		
	# player 2 win state vertical
	if grid_state[0] == 2 and grid_state[3] == 2 and grid_state[6] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(0, 610, 450)
	if grid_state[1] == 2 and grid_state[4] == 2 and grid_state[7] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(0, 840, 450)
	if grid_state[2] == 2 and grid_state[5] == 2 and grid_state[8] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(0, 1060, 450)
	
	# player 2 win state diagonal
	if grid_state[0] == 2 and grid_state[4] == 2 and grid_state[8] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(-45, 840, 450)
	if grid_state[2] == 2 and grid_state[4] == 2 and grid_state[6] == 2:
		player_won = "Player2"
		game_state = GameOver
		print("Player 2 Won")
		set_win_indicator(45, 840, 450)

#--------- mouse entered area check -----------
func _on_G1_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g1"
	sprite_pos = Vector2(610, 210)
func _on_G2_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g2"
	sprite_pos = Vector2(840, 210)
func _on_G3_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g3"
	sprite_pos = Vector2(1060, 210)
func _on_G4_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g4"
	sprite_pos = Vector2(610, 450)
func _on_G5_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g5"
	sprite_pos = Vector2(840, 450)
func _on_G6_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g6"
	sprite_pos = Vector2(1060, 450)
func _on_G7_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g7"
	sprite_pos = Vector2(610, 690)
func _on_G8_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g8"
	sprite_pos = Vector2(840, 690)
func _on_G9_mouse_entered() -> void:
	mouse_over_board = true
	current_grid_select = "g9"
	sprite_pos = Vector2(1060, 690)

#--------- mouse exited area check ------------
func _on_G1_mouse_exited() -> void:
	mouse_over_board = false
func _on_G2_mouse_exited() -> void:
	mouse_over_board = false
func _on_G3_mouse_exited() -> void:
	mouse_over_board = false
func _on_G4_mouse_exited() -> void:
	mouse_over_board = false
func _on_G5_mouse_exited() -> void:
	mouse_over_board = false
func _on_G6_mouse_exited() -> void:
	mouse_over_board = false
func _on_G7_mouse_exited() -> void:
	mouse_over_board = false
func _on_G8_mouse_exited() -> void:
	mouse_over_board = false
func _on_G9_mouse_exited() -> void:
	mouse_over_board = false
