extends Node2D

enum _State {
	AWATING_JAR_TOUCH,
	DRAGGING_JAR,
	JAR_FLOATING_HOME,
	JAR_HEATING
}

var _jar : Node2D
var _state = null

var _new_stovetop_polygon : PoolVector2Array
var _new_done_area_polygon : PoolVector2Array

onready var _stovetop = $StoveTop
onready var _done_area = $DoneArea
onready var _jar_spawner = $JarSpawner
onready var _jar_holder = $JarHolder

onready var _heat_timer = $StoveTop/HeatTimer
onready var _progress_bar = $StoveTop/ProgressBar
onready var _checkmark = $StoveTop/Checkmark

func _ready():
	_set_up_polygons()
	_jar = _spawn_jar(_jar_holder.position)
	_set_state(_State.AWATING_JAR_TOUCH)


func _set_up_polygons()->void:
	for point in _stovetop.get_polygon_points():
		_new_stovetop_polygon.append(point + _stovetop.get_polygon().global_position)
	for point in _done_area.get_polygon_points():
		_new_done_area_polygon.append(point + _done_area.get_polygon().global_position)


func _on_Jar_touched()->void:
	match _state:
		_State.AWATING_JAR_TOUCH:
			_set_state(_State.DRAGGING_JAR)


func _input(event: InputEvent) -> void:
	match _state:
		_State.DRAGGING_JAR:
			if _jar.is_draggable:
				if event is InputEventMouseMotion:
					_jar.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var _above_stovetop := Geometry.is_point_in_polygon(
						_jar.position, _new_stovetop_polygon)
					if _above_stovetop:
						print ("on stovetop")
						_set_state(_State.JAR_HEATING)
					else:
						print ("anywhere else")
						_set_state(_State.AWATING_JAR_TOUCH)


func _set_state(new_state)->void:
	# Handle logic when leaving state
	match _state:
		_State.AWATING_JAR_TOUCH:
			pass
		_State.DRAGGING_JAR:
			pass
	
	# Update variable
	_state = new_state
	
	#entering state
	match new_state:
		_State.AWATING_JAR_TOUCH:
			if _jar.is_draggable:
				if not _jar.is_connected("touched", self, "_on_Jar_touched"):
					# warning-ignore:return_value_discarded
					_jar.connect("touched", self, "_on_Jar_touched")
		_State.JAR_HEATING:
			_jar.disconnect("touched", self, "_on_Jar_touched")
			_jar.done = true
			_jar.set_sprite("TopDownView") #SideView
			
			


func _spawn_jar(pos:Vector2)->Node2D:
	#_jar signals disconnected where _jar is done
	_jar = preload("res://JarSanitizationStation/Jar/Jar.tscn").instance()
	_jar_spawner.add_child(_jar)
	_jar.position = pos
	return _jar
	


func _on_Timer_timeout():
	pass # Replace with function body.
