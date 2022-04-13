extends Node

const DEFAULT_PORT := 3333
var CARROT_CHUNKS := 0

remote func _start_prep_station() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_prep_station")
	_load_prep_station()

remote func _load_prep_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://PrepStation/PrepStation.tscn")


remote func _update_carrot_chunk_count() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer in get_tree().get_network_connected_peers():
		rpc_id(peer, "_add_carrot_chunk")
	_add_carrot_chunk()


remote func _add_carrot_chunk() -> void:
	CARROT_CHUNKS += 1

remote func _request_add_carrot_chunk() -> void:
	rpc_id(1, "_update_carrot_chunk_count")
