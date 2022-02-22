extends Node

const DEFAULT_PORT := 3333

remote func _start_message_sender() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_message_sender")
	_load_message_sender()

remote func _load_message_sender() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MessageSender/MessageSender.tscn")
