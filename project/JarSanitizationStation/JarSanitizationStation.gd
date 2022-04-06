extends Node2D

var _jar : Node2D

func _ready():
	_jar = _spawn_jar($JarSpawnArea.position)

func _spawn_jar(pos:Vector2) -> Node2D:
	_jar = preload("res://JarSanitizationStation/Jar/Jar.tscn").instance()
	$JarSpawnArea.add_child(_jar)
	
	return _jar
