extends Control


func _on_CreateServer_pressed():
	$CreateServerButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostLobby/HostLobby.tscn")

func _on_JoinServer_pressed():
	$JoinServerButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://JoinServer/JoinServer.tscn")	
