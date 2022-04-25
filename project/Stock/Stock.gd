extends Node

signal chunk_sets_changed(new_count)
signal sanitized_jars_changed(new_count)
signal filled_jars_changed(new_count)

var chunk_sets := 0
var sanitized_jars := 0
var filled_jars := 0

remote func add_carrot() -> void:
	if get_tree().is_network_server(): 
		chunk_sets += 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_chunk_sets_changed", chunk_sets)
		_emit_chunk_sets_changed(chunk_sets)
	else:
		rpc_id(1, "add_carrot")


remote func remove_carrot() -> void:
	if get_tree().is_network_server(): 
		chunk_sets -= 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_chunk_sets_changed", chunk_sets)
		_emit_chunk_sets_changed(chunk_sets)
	else:
		rpc_id(1, "remove_carrot")


remote func _emit_chunk_sets_changed(count:int) -> void:
	chunk_sets = count
	emit_signal("chunk_sets_changed", count)








remote func add_sanitized_jar() -> void:
	if get_tree().is_network_server():
		sanitized_jars += 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_sanitized_jars_changed", sanitized_jars)
		_emit_sanitized_jars_changed(sanitized_jars)
	else:
		rpc_id(1, "add_sanitized_jar")


remote func remove_sanitized_jar() -> void:
	if get_tree().is_network_server():
		sanitized_jars -= 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_sanitized_jars_changed", sanitized_jars)
		_emit_sanitized_jars_changed(sanitized_jars)
	else:
		rpc_id(1, "remove_sanitized_jar")


remote func _emit_sanitized_jars_changed(count:int) -> void:
	sanitized_jars = count
	emit_signal("sanitized_jars_changed", count)









remote func add_filled_jar() -> void:
	if get_tree().is_network_server():
		filled_jars += 1
		remove_carrot()
		remove_sanitized_jar()
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_filled_jars_changed", filled_jars)
		_emit_filled_jars_changed(filled_jars)
	else:
		rpc_id(1, "add_filled_jar")


remote func _emit_filled_jars_changed(count:int) -> void:
	filled_jars = count
	emit_signal("filled_jars_changed", count)


remote func clear_stock() -> void:
	chunk_sets = 0
	sanitized_jars = 0
	filled_jars = 0
