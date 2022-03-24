extends Control

onready var devicesConnected = 0
onready var filteredIps = []

func _ready():
	var ips = IP.get_local_addresses()
	for ip in ips:
		if ip.count(".") > 0:
			filteredIps.append(ip)
	$IpAddressLabel.text = filteredIps[0]
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


func _on_GoBackButton_pressed():
	$DevicesConnectedAlert.visible = false


func _on_ContinueButton_pressed():
	get_tree().network_peer.close_connection()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")


func _on_StartGameButton_pressed():
	Server._load_message_sender()


func _on_IpDidntWorkButton_pressed():
	$IpDidntWorkButton.disabled = true
	$IpDidntWorkButton.visible = false
	$IpAddressLabel.text += "\nAdditional Ips:\n"
	for i in range(1, len(filteredIps)):
		$IpAddressLabel.text += filteredIps[i] + "\n"
