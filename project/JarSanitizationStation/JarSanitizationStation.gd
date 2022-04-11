extends Node2D

enum _State {
	AWATING_JAR_TOUCH,
	DRAGGING_JAR,
	JAR_FLOATING_HOME,
	JAR_HEATING,
	JAR_SANITIZED
}

export var float_animation_duration := 0.5

var _jar : Node2D
var _state = null
var _new_stovetop_polygon : PoolVector2Array
var _new_done_area_polygon : PoolVector2Array
var _seconds_count := 0

var _jar_home_pos : Vector2

onready var _stovetop = $StoveTop
onready var _done_area = $DoneArea
onready var _jar_spawner = $JarSpawner
onready var _jar_holder = $JarHolder

onready var _heat_timer = $StoveTop/HeatTimer
onready var _progress_bar = $StoveTop/ProgressBar
onready var _checkmark = $StoveTop/Checkmark
onready var _checkmark_sound = $CheckmarkSound

func _ready():
	_set_up_polygons()
	_jar = _spawn_jar(_jar_holder.position)
	_set_state(_State.AWATING_JAR_TOUCH)
	_checkmark.visible = false


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
					var _above_done_area := Geometry.is_point_in_polygon(
						_jar.position, _new_done_area_polygon)
					
					if _above_stovetop and not _jar.is_sanitized:
						print ("on stovetop stuck")
						_jar_home_pos = _jar.global_position
						_set_state(_State.JAR_HEATING)
					elif _above_done_area and _jar.is_sanitized:
						print("on done area")
						_jar.set_sprite("SideView")
						_jar.disconnect("touched", self, "_on_Jar_touched")
						
						_progress_bar.value = 0
						_checkmark.visible = false
						
						_jar = _spawn_jar(_jar_holder.position)
						_set_state(_State.AWATING_JAR_TOUCH)
					else:
						print ("anywhere else")
						_set_state(_State.JAR_FLOATING_HOME)


func _set_state(new_state)->void:
	# Handle logic when leaving state
	match _state:
		_State.JAR_HEATING:
			_jar.done = false
			_jar.is_sanitized = true
	
	# Update variable
	_state = new_state
	
	#entering state
	match new_state:
		_State.AWATING_JAR_TOUCH:
			if _jar.is_draggable:
				if not _jar.is_connected("touched", self, "_on_Jar_touched"):
					# warning-ignore:return_value_discarded
					_jar.connect("touched", self, "_on_Jar_touched")
				_jar.is_glowing = true
			_done_area.is_glowing = false
			
			if _jar.is_sanitized:
				move_child(_jar_spawner, 4)
			
		_State.DRAGGING_JAR:
			_jar.is_glowing = false
			move_child(_jar_spawner, 5)
			if _jar.is_sanitized:
				_done_area.is_glowing = true
			else:
				_stovetop.is_glowing = true
			
		_State.JAR_HEATING:
			_stovetop.is_glowing = false
			move_child(_jar_spawner, 4)
			_jar.disconnect("touched", self, "_on_Jar_touched")
			_jar.done = true
			_jar.set_sprite("TopDownView")
			_heat_timer.start()
			
		_State.JAR_FLOATING_HOME:
			_stovetop.is_glowing = false
			_done_area.is_glowing = false
			var _tween := Tween.new()
			add_child(_tween)
			# warning-ignore:return_value_discarded
			_tween.connect("tween_completed", self, "_set_state_to_awaiting_jar_touch")
			# warning-ignore:return_value_discarded
			_tween.interpolate_property(
				_jar, "position", 
				_jar.position, _jar_home_pos, 
				float_animation_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			# warning-ignore:return_value_discarded
			_tween.start()


func _spawn_jar(pos:Vector2)->Node2D:
	#_jar signals disconnected where _jar is done
	_jar = preload("res://JarSanitizationStation/Jar/Jar.tscn").instance()
	_jar_spawner.add_child(_jar)
	_jar.position = pos
	_jar_home_pos = _jar.global_position
	return _jar


func _on_HeatTimer_timeout():
	_seconds_count += 1
	_progress_bar.value += 1
	if _seconds_count == 4:
		_checkmark_sound.play()
		_checkmark.visible = true
		_seconds_count = 0
		_set_state(_State.AWATING_JAR_TOUCH)
		_heat_timer.stop()


func _set_state_to_awaiting_jar_touch(_obj, _key):
	_set_state(_State.AWATING_JAR_TOUCH)
