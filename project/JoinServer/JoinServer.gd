extends Control

onready var ipAddress = $IpAdressEdit

func _ready():
	$JoinButton.disabled = true
	

func _on_IpAdressEdit_text_changed(_new_text):
	$JoinButton.disabled = false


func _on_HelpButton_pressed():
	$HelpPopup.visible = true


func _on_HideHelpButton_pressed():
	$HelpPopup.visible = false
	
func _on_HideErrorButton_pressed():
	$CannnotConnectPopup.visible = false


func _on_JoinButton_pressed():
	var client = NetworkedMultiplayerENet.new()
	var clientCreated = client.create_client(ipAddress.text, Server.DEFAULT_PORT)
	get_tree().network_peer = client
	ipAddress.text = ""
	if clientCreated != OK:
		$CannnotConnectPopup.visible = true
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://ConnectionSuccessful/ConnectionSuccessful.tscn")




func _on_GoBackButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")
