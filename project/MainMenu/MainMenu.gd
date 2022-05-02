extends Control

func _on_CreateServer_pressed():
	$ButtonClick.play()
	$CreateServerButton.disabled = true
	var server = NetworkedMultiplayerENet.new()
	server.create_server(Server.DEFAULT_PORT)
	get_tree().network_peer = server
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostLobby/HostLobby.tscn")


func _on_JoinServer_pressed():
	$ButtonClick.play()
	$JoinServerButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://JoinServer/JoinServer.tscn")
