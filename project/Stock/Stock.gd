extends Node

signal chunk_sets_changed(new_count)
signal sanitized_jars_changed(new_count)
signal filled_jars_changed(new_count)

signal sanitized_jar_sent()
signal chunks_sent()

var chunk_sets := 0
var sanitized_jars := 0
var filled_jars := 0

var _awaiting_jar_queue: Array = []
var _awaiting_chunks_queue: Array = []


remote func add_carrot() -> void:
	if get_tree().is_network_server(): 
		chunk_sets += 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_chunk_sets_changed", chunk_sets)
		_emit_chunk_sets_changed(chunk_sets)
		_check_chunks_queue()
	else:
		rpc_id(1, "add_carrot")


func _check_chunks_queue() -> void:
	if not _awaiting_chunks_queue.empty():
		var intended_receiver_id = _awaiting_chunks_queue.pop_front()
		_send_chunk_set_to_filling_station(intended_receiver_id)


remote func _emit_chunk_sets_changed(count:int) -> void:
	chunk_sets = count
	emit_signal("chunk_sets_changed", count)


remote func add_sanitized_jar() -> void:
	if get_tree().is_network_server():
		sanitized_jars += 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_sanitized_jars_changed", sanitized_jars)
		_emit_sanitized_jars_changed(sanitized_jars)
		_check_sanitized_jar_queue()
	else:
		rpc_id(1, "add_sanitized_jar")
		
		
func _check_sanitized_jar_queue() -> void:
	if not _awaiting_jar_queue.empty():
		var intended_receiver_id = _awaiting_jar_queue.pop_front()
		_send_jar_to_filling_station(intended_receiver_id)


remote func _emit_sanitized_jars_changed(count:int) -> void:
	sanitized_jars = count
	emit_signal("sanitized_jars_changed", count)


remote func add_filled_jar() -> void:
	if get_tree().is_network_server():
		filled_jars += 1
		for peer_id in get_tree().get_network_connected_peers():
			rpc_id(peer_id, "_emit_filled_jars_changed", filled_jars)
		_emit_filled_jars_changed(filled_jars)
	else:
		rpc_id(1, "add_filled_jar")


remote func _emit_filled_jars_changed(count:int) -> void:
	filled_jars = count
	emit_signal("filled_jars_changed", count)


remote func request_sanitize_jar() -> void:
	if get_tree().is_network_server():
		update_awaiting_jar_queue()
	else:
		rpc_id(1, "update_awaiting_jar_queue")


remote func _send_jar_to_filling_station(intended_receiver_id) -> void:
	assert(get_tree().is_network_server(), "Should only be called on server")
	rpc_id(intended_receiver_id, "_emit_sanitized_jar_sent")
	sanitized_jars -= 1
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_emit_sanitized_jars_changed", sanitized_jars)
	_emit_sanitized_jars_changed(sanitized_jars) 
		
		
remote func update_awaiting_jar_queue() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server")
	var client_id = multiplayer.get_rpc_sender_id()
	if _awaiting_jar_queue.empty() and sanitized_jars > 0:
		_send_jar_to_filling_station(client_id)
	else:
		_awaiting_jar_queue.append(client_id)


remote func _emit_sanitized_jar_sent() -> void:
	emit_signal("sanitized_jar_sent")


remote func request_chunks() -> void:
	if get_tree().is_network_server():
		update_chunks_queue()
	else:
		rpc_id(1, "update_chunks_queue")


remote func _send_chunk_set_to_filling_station(intended_receiver_id) -> void:
	assert(get_tree().is_network_server(), "Should only be called on server")
	rpc_id(intended_receiver_id, "_emit_chunks_sent")
	chunk_sets -= 1
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_emit_chunk_sets_changed", chunk_sets)
	_emit_chunk_sets_changed(chunk_sets)


remote func update_chunks_queue() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server")
	var client_id = multiplayer.get_rpc_sender_id()
	if _awaiting_chunks_queue.empty() and chunk_sets > 0:
		_send_chunk_set_to_filling_station(client_id)
	else:
		_awaiting_chunks_queue.append(client_id)


remote func _emit_chunks_sent() -> void:
	emit_signal("chunks_sent")
	
	
remote func clear_stock() -> void:
	chunk_sets = 0
	sanitized_jars = 0
	filled_jars = 0
