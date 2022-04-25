extends Control

func _ready():
	$Backdrop/ChopCarrotAnimation

func _on_ReadyButton_pressed():
	Server.start_game()
