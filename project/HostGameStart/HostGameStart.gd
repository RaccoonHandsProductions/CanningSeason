extends Control


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_show_popup")


func _on_SettingsLink_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostLobby/HostLobby.tscn")


func _on_StartButton_pressed():
	# warning-ignore:return_value_discarded
	Server._start_message_sender()


func _on_GoBackButton_pressed():
	$PlayerDisconnectedPopup.visible = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostLobby/HostLobby.tscn")

func _show_popup(_id):
	$PlayerDisconnectedPopup.visible = true
