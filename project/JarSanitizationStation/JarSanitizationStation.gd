extends Node2D

enum _State {
	AWATING_JAR_TOUCH,
	DRAGGING_JAR,
	JAR_FLOATING_HOME,
}

var _jar : Node2D
var _state = null

func _ready():
	_jar = _spawn_jar($JarSpawnArea.position)
	
func _spawn_jar(pos:Vector2) -> Node2D:
	_jar = preload("res://JarSanitizationStation/Jar/Jar.tscn").instance()
	$JarSpawnArea.add_child(_jar)
	
	return _jar

func _on_jar_touched()->void:
	match _state:
		_State.AWATING_JAR_TOUCH:
			_set_state(_State.DRAGGING_JAR)
	
func _set_state(new_state)->void:
	_state = new_state
	
	match new_state:
		_State.AWATING_JAR_TOUCH:
			_jar.connect("touched", self, "_on_jar_touched")
		_State.DRAGGING_JAR:
			print("dragging")
		_State.JAR_FLOATING_HOME:
			pass


