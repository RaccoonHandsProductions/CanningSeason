extends Control

func _ready():
	$JoinButton.disabled = true
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_on_connection_successful")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_on_connection_failed")


func _on_HelpButton_pressed():
	$ButtonClick.play()
	$HelpPopup.visible = true


func _on_HideHelpButton_pressed():
	$ButtonClick.play()
	$HelpPopup.visible = false
	
	
func _on_HideErrorButton_pressed():
	$ButtonClick.play()
	$CannnotConnectPopup.visible = false


func _on_JoinButton_pressed():
	$ButtonClick.play()
	_show_connecting_animation()
	$JoinButton.disabled = true
	var client = NetworkedMultiplayerENet.new()
	var client_connected = client.create_client($IPEntryControl._get_ip_address(), Server.DEFAULT_PORT)
	get_tree().network_peer = client
	if client_connected != OK:
		_hide_connecting_animation()
		$JoinButton.disabled = false
		$CannnotConnectPopup.visible = true


func _on_GoBackButton_pressed():
	$ButtonClick.play()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")


func _on_connection_successful():
	_hide_connecting_animation()
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ConnectionSuccessful/ConnectionSuccessful.tscn")

func _on_connection_failed():
	_hide_connecting_animation()
	$JoinButton.disabled = false
	$IPEntryControl.visible = true
	$CannnotConnectPopup.visible = true
	
	
func _show_connecting_animation():
	$IPEntryControl.visible = false
	$ConnectingAnimation.visible = true
	$ConnectingLabel.visible = true
	
	
func _hide_connecting_animation():
	$ConnectingAnimation.visible = false
	$ConnectingLabel.visible = false

func _on_IPEntryControl_button_clicked():
	$ButtonClick.play()
	$JoinButton.disabled = false
