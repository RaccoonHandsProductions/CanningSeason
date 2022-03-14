extends Control

var devicesConnected = 0

func _ready():
	if OS.get_name() == "Android":
		$IpAddressLabel.text = IP.get_local_addresses()[0]
	else:	
		$IpAddressLabel.text = IP.resolve_hostname( str(OS.get_environment("COMPUTERNAME")), 1)
	$OtherDevicesLabel.text = "There are " + str(devicesConnected) + " devices conencted."
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_add_device_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_remove_device")
	
func _on_HelpButton_pressed():
	$HelpPopup.visible = true

func _on_HideHelpButton_pressed():
	$HelpPopup.visible = false

func _on_Disconnect_pressed():
	if get_tree().get_network_connected_peers().size() == 0:
		get_tree().network_peer.close_connection()
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://MainMenu/MainMenu.tscn")
	else:
		$DevicesConnectedAlert/PlayersConnected.text = "You currently have "+str(devicesConnected)+" other devices connected."
		$DevicesConnectedAlert.visible = true
	
func _add_device_connected(_id):
	devicesConnected += 1
	$OtherDevicesLabel.text = "There are " + str(devicesConnected) + " devices connected."
	
func _remove_device(_id):
	devicesConnected -= 1
	$OtherDevicesLabel.text = "There are " + str(devicesConnected) + " devices connected."


func _on_AllPlayersConnectedButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://HostGameStart/HostGameStart.tscn")


func _on_GoBackButton_pressed():
	$DevicesConnectedAlert.visible = false


func _on_ContinueButton_pressed():
	get_tree().network_peer.close_connection()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
