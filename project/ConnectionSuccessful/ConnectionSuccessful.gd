extends Control

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")

func _on_DisconnectButton_pressed():
	get_tree().network_peer.close_connection()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")

func _on_MainMenuButton_pressed():
	$ServerDisconnectedPopup.visible = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")


func _on_JoinServerButton_pressed():
	$ServerDisconnectedPopup.visible = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://JoinServer/JoinServer.tscn")
	
func _on_server_disconnected():
	$ServerDisconnectedPopup.visible = true
