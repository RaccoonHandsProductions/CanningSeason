extends Node

const DEFAULT_PORT := 3333

const _PrepStation := preload("res://PrepStation/PrepStation.tscn")
const _JarSanitizationStation := preload("res://JarSanitizationStation/JarSanitizationStation.tscn")
const _FillingStation := preload("res://FillingStation/FillingStation.tscn")

var CARROT_CHUNKS := 0
var SANITIZED_JARS := 0
var FILLED_JARS := 0
var index := 0

var stations = [
	"_load_prep_station",
	"_load_jar_sanitization_station", 
	"_load_filling_station",
]

remote func start_game() -> void:
	Stock.clear_stock()
	assert(get_tree().is_network_server(), "Should only be called on server.")
	var number_of_stations : int = stations.size()
	
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, stations[index % number_of_stations])
		index = index + 1
		
	call(stations[index % number_of_stations])


remote func _load_prep_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_PrepStation)


remote func _update_carrot_chunk_count() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer in get_tree().get_network_connected_peers():
		rpc_id(peer, "_add_carrot_chunk")
	_add_carrot_chunk()


remote func _add_carrot_chunk() -> void:
	CARROT_CHUNKS += 1


remote func _request_add_carrot_chunk() -> void:
	rpc_id(1, "_update_carrot_chunk_count")


remote func _start_jar_sanitization_station() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_jar_sanitization_station")
	_load_jar_sanitization_station()


remote func _load_jar_sanitization_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_JarSanitizationStation)


remote func _update_sanitized_jar_count() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer in get_tree().get_network_connected_peers():
		rpc_id(peer, "_add_sanitized_jar")
	_add_sanitized_jar()


remote func _add_sanitized_jar() -> void:
	SANITIZED_JARS += 1


remote func _request_add_sanitized_jar() -> void:
	rpc_id(1, "_update_sanitized_jar_count")


remote func _start_filling_station() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_filling_station")
	_load_filling_station()


remote func _load_filling_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_FillingStation)


remote func _update_filled_jar_count() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer in get_tree().get_network_connected_peers():
		rpc_id(peer, "_add_filled_jar")
	_add_filled_jar()


remote func _add_filled_jar() -> void:
	FILLED_JARS += 1


remote func _request_add_filled_jar() -> void:
	rpc_id(1, "_update_filled_jar_count")





