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
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ipAddress.text, Server.DEFAULT_PORT)
	get_tree().network_peer = client
	ipAddress.text = ""
	var id = get_tree().get_network_unique_id()
	print(id)

func _on_GoBackButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainMenu/MainMenu.tscn")

func _on_connection_successful():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ConnectionSuccessful/ConnectionSuccessful.tscn")

func _on_connection_failed():
	$JoinButton.disabled = true
	$CannnotConnectPopup.visible = true
