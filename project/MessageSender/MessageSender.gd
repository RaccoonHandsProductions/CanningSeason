extends Control

onready var _messageLabel = $ReceivedMessage

func _on_Button_pressed():
	$ButtonClick.play()
	if get_tree().is_network_server():
		_send_message($MessageInput.text)
	else:
		rpc_id(1, "_send_message", $MessageInput.text)

remote func _send_message(message:String) -> void:
	assert(get_tree().is_network_server(), "Should only be called on server")
	if (get_tree().get_rpc_sender_id() != 0):
		_update_message_label(message)
	for peer_id in get_tree().get_network_connected_peers():
		if (peer_id != get_tree().get_rpc_sender_id()):
			rpc_id(peer_id, '_update_client_message_label', message)
	
remote func _update_client_message_label(message:String) -> void:
	assert(not get_tree().is_network_server(), "Should only be called on client")
	_update_message_label(message)
	
func _update_message_label(message:String) -> void:
	_messageLabel.text = message
