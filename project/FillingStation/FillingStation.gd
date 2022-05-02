extends Node2D


enum _State{
	AWAITING_JAR_TOUCH,
	DRAGGING_JAR,
	JAR_FLOATING_HOME,
	AWAITING_CHUNKS_TOUCH,
	DRAGGING_CHUNKS,
	CHUNKS_FLOATING_HOME,
	AWAITING_FILLED_JAR_TOUCH,
	DRAGGING_FILLED_JAR,
	FILLED_JAR_FLOATING_HOME,
	WAITING_FOR_STOCK
}

export var float_animation_duration := 0.5

var _state = null
var _chunks : Node2D
var _jar : Node2D

var _new_filling_area_polygon : PoolVector2Array
var _new_done_area_polygon : PoolVector2Array

var _filled_jar_start_pos : Vector2

var _waiting_for_jar = true
var _waiting_for_chunks = true
var _initial_jar_spawning = true
var _initial_chunks_spawning = true

onready var _filling_area = $FillingArea
onready var _done_area = $DoneArea
onready var _jar_holder = $JarHolder
onready var _chunk_bowl = $ChunkBowl
onready var _raycast := $RayCast2D
onready var _jar_spawner := $JarSpawner
onready var _chunk_spawner := $ChunksSpawner

onready var _top_layer := get_child_count()
onready var _initial_chunks_layer = _chunk_spawner.get_index()


func _ready():
	Stock.clear_stock()
	for point in _filling_area.get_polygon_points():
		_new_filling_area_polygon.append(point + _filling_area.get_polygon().global_position)
	for point in _done_area.get_polygon_points():
		_new_done_area_polygon.append(point + _done_area.get_polygon().global_position)
	
	# warning-ignore:return_value_discarded
	_spawn_chunks(_chunk_bowl.position)
	# warning-ignore:return_value_discarded
	_spawn_jar(_jar_holder.position)
	_set_state(_State.AWAITING_JAR_TOUCH)

# warning-ignore:return_value_discarded
	Stock.connect("sanitized_jar_sent", self, "_on_sanitized_jar_sent")
# warning-ignore:return_value_discarded
	Stock.connect("chunks_sent", self, "_on_chunks_sent")


func _input(event: InputEvent) -> void:
	match _state:
		_State.DRAGGING_JAR:
			if _jar.is_draggable:
				if event is InputEventMouseMotion:
					_jar.position += event.relative
					_filling_area.is_glowing = true
				elif event is InputEventMouseButton and not event.is_pressed():
					var _above_filling_area := Geometry.is_point_in_polygon(
						_jar.position, _new_filling_area_polygon)
					if _above_filling_area:
						$JarSound.play()
						_set_state(_State.AWAITING_CHUNKS_TOUCH)
					else:
						_set_state(_State.JAR_FLOATING_HOME)
					
		_State.DRAGGING_CHUNKS:
			if _chunks.is_draggable:
				if event is InputEventMouseMotion:
					_chunks.position += event.relative
					_jar.is_glowing = true
				elif event is InputEventMouseButton and not event.is_pressed():
					_raycast.position = event.position
					_raycast.force_raycast_update()
					var collider = _raycast.get_collider()
					if collider == _jar:
						$ChunkSound.play()
						_jar.fill_jar()
						_chunks.queue_free()
						_set_state(_State.AWAITING_FILLED_JAR_TOUCH)
					else:
						_set_state(_State.CHUNKS_FLOATING_HOME)
			
		_State.DRAGGING_FILLED_JAR:
			if _jar.is_draggable:
				if event is InputEventMouseMotion:
					_jar.position += event.relative
					_done_area.is_glowing = true
				elif event is InputEventMouseButton and not event.is_pressed():
					var _above_done_area := Geometry.is_point_in_polygon(
						_jar.position, _new_done_area_polygon)
					if _above_done_area:
						$Ping.play()
						$JarSound.play()
						$LidSound.play()
						_jar.place_lid()
						Stock.add_filled_jar()
						_set_state(_State.WAITING_FOR_STOCK)
					else:
						_set_state(_State.FILLED_JAR_FLOATING_HOME)


func _set_state(new_state)->void:
	# Handle logic when leaving state
	match _state:
		_State.AWAITING_JAR_TOUCH:
			_jar.is_glowing = false
			move_child(_jar_spawner, _top_layer)
		_State.DRAGGING_JAR:
			_filling_area.is_glowing = false
		_State.AWAITING_CHUNKS_TOUCH:
			_chunks.is_glowing = false
			move_child(_chunk_spawner, _top_layer)
		_State.DRAGGING_CHUNKS:
			_jar.is_glowing = false
		_State.AWAITING_FILLED_JAR_TOUCH:
			_jar.is_glowing = false
		_State.DRAGGING_FILLED_JAR:
			_done_area.is_glowing = false

	# Update variable
	_state = new_state

	#entering state
	match new_state:
		_State.AWAITING_JAR_TOUCH:
			_waiting_for_jar = true
			_waiting_for_chunks = true
			_jar.is_draggable = true
			_jar.is_glowing = true
			if _jar.is_draggable:
				_jar.done = false
				
				if not _jar.is_connected("touched", self, "_on_jar_touched"): # or not _carrot.is_connected("piece_made", self, "_on_Carrot_piece_made"):
					# warning-ignore:return_value_discarded
					_jar.connect("touched", self, "_on_jar_touched")

		_State.JAR_FLOATING_HOME:
			var _tween := Tween.new()
			add_child(_tween)
			# warning-ignore:return_value_discarded
			_tween.connect("tween_completed", self, "_set_state_to_awaiting_jar_touch")
			# warning-ignore:return_value_discarded
			_tween.interpolate_property(
				_jar, "position", 
				_jar.position, _jar_holder.position, 
				float_animation_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			# warning-ignore:return_value_discarded
			_tween.start()

		_State.AWAITING_CHUNKS_TOUCH:
			_chunks.is_draggable = true
			_chunks.is_glowing = true
			if _chunks.is_draggable:
				_chunks.done = false
				
				if not _chunks.is_connected("touched", self, "_on_chunks_touched"): # or not _carrot.is_connected("piece_made", self, "_on_Carrot_piece_made"):
					# warning-ignore:return_value_discarded
					_chunks.connect("touched", self, "_on_chunks_touched")
		
		_State.CHUNKS_FLOATING_HOME:
			var _tween := Tween.new()
			add_child(_tween)
			# warning-ignore:return_value_discarded
			_tween.connect("tween_completed", self, "_set_state_to_awaiting_chunks_touch")
			# warning-ignore:return_value_discarded
			_tween.interpolate_property(
				_chunks, "position", 
				_chunks.position, _chunk_bowl.position, 
				float_animation_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			# warning-ignore:return_value_discarded
			_tween.start()
		
		_State.AWAITING_FILLED_JAR_TOUCH:
			_jar.done = false
			_jar.is_glowing = true
			_filled_jar_start_pos = _jar.position
		
		_State.FILLED_JAR_FLOATING_HOME:
			var _tween := Tween.new()
			add_child(_tween)
			# warning-ignore:return_value_discarded
			_tween.connect("tween_completed", self, "_set_state_to_awaiting_filled_jar_touch")
			# warning-ignore:return_value_discarded
			_tween.interpolate_property(
				_jar, "position", 
				_jar.position, _filled_jar_start_pos, 
				float_animation_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN)
			# warning-ignore:return_value_discarded
			_tween.start()
		
		_State.WAITING_FOR_STOCK:
			# warning-ignore:return_value_discarded
			Stock.request_sanitize_jar()
			Stock.request_chunks()


func _check_waiting_state() -> void:
	if not _waiting_for_jar and not _waiting_for_chunks:
		_set_state(_State.AWAITING_JAR_TOUCH)


func _set_state_to_awaiting_jar_touch(_obj, _key):
	_set_state(_State.AWAITING_JAR_TOUCH)


func _set_state_to_awaiting_chunks_touch(_obj, _key):
	_set_state(_State.AWAITING_CHUNKS_TOUCH)


func _set_state_to_awaiting_filled_jar_touch(_obj, _key):
	_set_state(_State.AWAITING_FILLED_JAR_TOUCH)


func _on_chunks_touched()->void:
	match _state:
		_State.AWAITING_CHUNKS_TOUCH:
			_set_state(_State.DRAGGING_CHUNKS)


func _on_jar_touched()->void:
	match _state:
		_State.AWAITING_JAR_TOUCH:
			_set_state(_State.DRAGGING_JAR)
		_State.AWAITING_FILLED_JAR_TOUCH:
			_set_state(_State.DRAGGING_FILLED_JAR)


func _spawn_chunks(pos:Vector2) -> Node2D:
	_chunks = preload("res://FillingStation/Chunks/Chunks.tscn").instance()
	$ChunksSpawner.add_child(_chunks)
	_chunks.position = pos
	_waiting_for_chunks = false
	_check_waiting_state()
	_initial_chunks_spawning = false
	return _chunks


func _spawn_jar(pos:Vector2) -> Node2D:
	if not _initial_jar_spawning:
		_jar.disconnect("touched", self, "_on_jar_touched")
	_jar = preload("res://FillingStation/Jar/FillJar.tscn").instance()
	$JarSpawner.add_child(_jar)
	_jar.position = pos
	_waiting_for_jar = false
	_check_waiting_state()
	_initial_jar_spawning = false
	return _jar


func _on_sanitized_jar_sent():
	_spawn_jar(_jar_holder.position)


func _on_chunks_sent():
	_spawn_chunks(_chunk_bowl.position)
