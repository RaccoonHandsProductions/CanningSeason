extends Control

func _on_ExitButton_pressed():
	$ButtonClick.play()
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
