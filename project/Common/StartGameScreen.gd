extends Control

func _on_start_game_button_pressed():
	$ButtonClick.play()
	Server.start_instructions()
