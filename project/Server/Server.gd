extends Node

const DEFAULT_PORT := 3333

const _PrepStation := preload("res://PrepStation/PrepStation.tscn")
const _JarSanitizationStation := preload("res://JarSanitizationStation/JarSanitizationStation.tscn")
const _FillingStation := preload("res://FillingStation/FillingStation.tscn")

var InstructionsScript = load("res://InstructionsScreen/InstructionsScreen.gd").new()
var _index := 0

var stations = [
	"_load_prep_station",
	"_load_jar_sanitization_station", 
	"_load_filling_station",
]

remote func start_game() -> void:
	_index = 0
	var number_of_stations : int = stations.size()
	for peer_id in get_tree().get_network_connected_peers():
		_index = _index + 1
		rpc_id(peer_id, stations[_index % number_of_stations])
	# Original host should never be a filling station
	# call(stations[0]) makes the station that hits the replay button to be set 
	# to prep_station
	# Original host will always be the next in the list to get a station so 
	# it'll be a sanitization station and never a filling station
	call(stations[0])


remote func start_instructions() -> void:
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_instructions_screen")
	_load_instructions_screen()


remote func start_start_game_screen() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_start_game_screen")
	_load_start_game_screen()


remote func _load_instructions_screen() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://InstructionsScreen/InstructionsScreen.tscn")


remote func _load_start_game_screen() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Common/StartGameScreen.tscn")


remote func _load_prep_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_PrepStation)


remote func _start_jar_sanitization_station() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_jar_sanitization_station")
	_load_jar_sanitization_station()


remote func _load_jar_sanitization_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_JarSanitizationStation)


remote func _start_filling_station() -> void:
	assert(get_tree().is_network_server(), "Should only be called on server.")
	for peer_id in get_tree().get_network_connected_peers():
		rpc_id(peer_id, "_load_filling_station")
	_load_filling_station()


remote func _load_filling_station() -> void:
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(_FillingStation)
