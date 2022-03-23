extends Control

onready var ipAddress = $IpAdressEdit

func _ready():
	$JoinButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connection_successful")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	

func _on_IpAdressEdit_text_changed(_new_text):
	$JoinButton.disabled = false


func _on_HelpButton_pressed():
	$HelpPopup.visible = true


func _on_HideHelpButton_pressed():
	$HelpPopup.visible = false
	
	
func _on_HideErrorButton_pressed():
	$CannnotConnectPopup.visible = false


func _on_JoinButton_pressed():
	_show_connecting_animation()
	$JoinButton.disabled = true
	var client = NetworkedMultiplayerENet.new()
	var client_connected = client.create_client(ipAddress.text, Server.DEFAULT_PORT)
	get_tree().network_peer = client
	if client_connected != OK:
		_hide_connecting_animation()
		$JoinButton.disabled = false
		$CannnotConnectPopup.visible = true
	ipAddress.text = ""


func _on_GoBackButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")


func _on_connection_successful():
	_hide_connecting_animation()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ConnectionSuccessful/ConnectionSuccessful.tscn")


func _on_connection_failed():
	_hide_connecting_animation()
	$JoinButton.disabled = false
	$CannnotConnectPopup.visible = true
	
	
func _show_connecting_animation():
	$ConnectingAnimation.visible = true
	$ConnectingLabel.visible = true
	
	
func _hide_connecting_animation():
	$ConnectingAnimation.visible = false
	$ConnectingLabel.visible = false
