extends Control


func _on_CreateServer_pressed():
	$CreateServerButton.disabled = true
	var server = NetworkedMultiplayerENet.new()
	server.create_server(Server.DEFAULT_PORT, 4)
	get_tree().network_peer = server
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostLobby/HostLobby.tscn")

func _on_JoinServer_pressed():
	$JoinServerButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://JoinServer/JoinServer.tscn")	


func _on_PrepStationButton_pressed():
	get_tree().change_scene("res://PrepStation/PrepStation.tscn")
