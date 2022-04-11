extends Node2D


enum _State {
	AWAITING_CARROT_TOUCH,
	DRAGGING_CARROT,
	AWAITING_KNIFE_CHOP, #deleting this state causes carrot to stick to cursor but game still functions weirdly
	AWAITING_PIECE_TOUCH,
	DRAGGING_PIECE,
	PIECE_FLOATING_HOME, #deleting this state causes child tree repositioning to not work.
}

export var carrot_float_animation_duration := 0.5
export var carrot_animation_duration := 0.5
export var piece_float_animation_duration := 0.2
# The duration of the animation between chop points
export var knife_chop_transition_animation_duration := 0.3
# The duration of the animation of knife from or to home
export var knife_offscreen_animation_duration := .75

var _done_bowl_count := 0
var _done_bowl_limit := 4
var _compost_bowl_count := 0
var _compost_bowl_limit := 1

var _carrot : Node2D
var _current_carrot_piece :Node2D= null
var _piece_home_pos : Vector2
#key = CarrotPiece node, value = CarrotPiece.pos
var _pieces := {} 

var _new_bowl_polygon : PoolVector2Array
var _new_compost_bowl_polygon : PoolVector2Array
var _new_cutting_board_polygon : PoolVector2Array

var _carrot_spawn_positions := [Vector2(617,88), Vector2(597, 155), Vector2(640, 209), Vector2(666, 105), Vector2(666, 172), Vector2(685, 132)]
var _carrots
var _carrot_count := 1
var _current_carrot_pos : Vector2

var _piece_node_location
var _state = null
var _game_over := false

onready var _cutting_board_polygon_2d := $CuttingBoard/Polygon2D
onready var _cutting_board := $CuttingBoard

onready var _chunk_drop_sound := $ChunkDropSound
onready var _carrot_drop_sound := $CarrotDropSound
onready var _chunk_return_sound := $ChunkReturnSound

onready var _done_bowl_polygon_2d = $DoneBowl/Polygon2D
onready var _done_bowl := $DoneBowl
onready var _compost_bowl_polygon_2d = $CompostBowl/Polygon2D
onready var _compost_bowl := $CompostBowl

onready var _knife = $Knife
onready var _frond = null


func _ready() -> void:
	#adjusts the points of the Polygon2Ds to match any offset made in the PrepStation scene editor
	for point in _done_bowl_polygon_2d.polygon:
		_new_bowl_polygon.append(point + _done_bowl_polygon_2d.global_position)

	for point in _compost_bowl_polygon_2d.polygon:
		_new_compost_bowl_polygon.append(point + _compost_bowl_polygon_2d.global_position)

	for point in _cutting_board_polygon_2d.polygon:
		_new_cutting_board_polygon.append(point + _cutting_board_polygon_2d.global_position)

	for pos in _carrot_spawn_positions:
		_carrot = _spawn_carrot(pos)

	_set_state(_State.AWAITING_CARROT_TOUCH)


func _process(_delta: float) -> void:
	if _game_over:
		get_tree().paused = true
		$HUD/TimeLabel.text = "GAME OVER"


func _input(event: InputEvent) -> void:
	match _state:
		_State.DRAGGING_CARROT:
			_cutting_board.is_glowing = true
			if _carrot.is_draggable:
				if event is InputEventMouseMotion:
					_carrot.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var _above_board := Geometry.is_point_in_polygon(
						_carrot.position, _new_cutting_board_polygon)

					if _above_board:
						_carrot_count += 1
						_carrot_drop_sound.play()
						$Carrots.move_child(_carrot, _carrots.size() - 1)
						_animate_Knife_to_next_chop_point(knife_offscreen_animation_duration)
						_carrot.done = true
						_set_state(_State.AWAITING_KNIFE_CHOP)
					else:
						var _tween := Tween.new()
						
						add_child(_tween)
						# warning-ignore:return_value_discarded
						_tween.connect("tween_completed", self, "_set_state_to_awaiting_carrot_touch")
						# warning-ignore:return_value_discarded
						_tween.interpolate_property(
							_carrot, "position", 
							_carrot.position, _current_carrot_pos, 
							carrot_float_animation_duration,
						Tween.TRANS_QUAD, Tween.EASE_IN)
						# warning-ignore:return_value_discarded
						_tween.start()

		_State.DRAGGING_PIECE:
			#if statement for if piece is in the bowl to avoid taking it out?
			if event is InputEventMouseMotion:
				_current_carrot_piece.position += event.relative
				_carrot.move_child(_current_carrot_piece, _carrot.get_child_count() - 1)
			elif event is InputEventMouseButton and not event.is_pressed():
				var _above_compost_bowl := Geometry.is_point_in_polygon(
					_current_carrot_piece.position + _carrot.position,
					_new_compost_bowl_polygon)
					
				if _current_carrot_piece.is_frond:
					if _above_compost_bowl:
						_chunk_drop_sound.play()
						_current_carrot_piece.rotation = rand_range(0,360)
						_current_carrot_piece.done = true
						_compost_bowl_count += 1
						print("Compost Bowl Count: " + str(_compost_bowl_count))
						if _check_bowls():
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
					else:
						_set_state(_State.PIECE_FLOATING_HOME) # -------------------------- THIS IS NOT A 'REAL' STATE
						_carrot.move_child(_current_carrot_piece, _piece_node_location)
						_animate_CarrotPiece_to_home(piece_float_animation_duration)
						_set_state(_State.AWAITING_PIECE_TOUCH)

				var _above_done_bowl := Geometry.is_point_in_polygon(
					_current_carrot_piece.position+_carrot.position,
					_new_bowl_polygon)
					
				if not _current_carrot_piece.is_frond:
					if _above_done_bowl:
						_chunk_drop_sound.play()
						_current_carrot_piece.rotation = rand_range(0,360)
						_done_bowl_count += 1
						print("Bowl Count: " + str(_done_bowl_count))
						_current_carrot_piece.done = true
						if _check_bowls():
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
							# warning-ignore:return_value_discarded
							_pieces.erase(_current_carrot_piece)
					else:
						if not _current_carrot_piece.done:
							_carrot.move_child(_current_carrot_piece, _piece_node_location)
							_set_state(_State.PIECE_FLOATING_HOME)
							_animate_CarrotPiece_to_home(piece_float_animation_duration)


func _set_state(new_state)->void:
	# Handle logic when leaving state
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_carrot.is_glowing = false
		_State.DRAGGING_CARROT:
			_cutting_board.is_glowing = false
		_State.DRAGGING_PIECE:
			_done_bowl.is_glowing = false
			_compost_bowl.is_glowing = false

	# Update variable
	_state = new_state

	#entering state
	match new_state:
		_State.AWAITING_CARROT_TOUCH:
			_carrots = $Carrots.get_children()
			_carrot = _carrots[_carrots.size() - _carrot_count]
			_carrot.is_draggable = true
			
			if _carrot.is_draggable:
				_carrot.is_glowing = true
				_pieces.clear()
				_current_carrot_pos = _carrot.position
				_carrot.done = false
				if not _carrot.is_connected("touched", self, "_on_Carrot_touched"): # or not _carrot.is_connected("piece_made", self, "_on_Carrot_piece_made"):
					# warning-ignore:return_value_discarded
					_carrot.connect("touched", self, "_on_Carrot_touched")
					# warning-ignore:return_value_discarded
					_carrot.connect("piece_made", self, "_on_Carrot_piece_made")
					var _error := _carrot.connect("piece_slid", self, "_on_Carrot_piece_slid")
					assert(_error==OK, "Connection failed with error " + str(_error))

		_State.AWAITING_PIECE_TOUCH:
			for piece in _pieces:
				if not piece.done:
					piece.is_glowing = true
				piece.is_draggable = true

		_State.DRAGGING_PIECE:
			_piece_node_location = _current_carrot_piece.get_index()
			if _current_carrot_piece.is_frond:
				_compost_bowl.is_glowing = true
			else:
				_done_bowl.is_glowing = true
				
			for piece in _pieces:
				piece.is_draggable = false
				piece.is_glowing = false


# Because this is bound to tween_completed, we have to have two arguments
# that are ignored.
func _set_state_to_awaiting_carrot_touch(_a, _b)->void:
	_set_state(_State.AWAITING_CARROT_TOUCH)


func _on_Carrot_touched()->void:
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_set_state(_State.DRAGGING_CARROT)


func _on_Carrot_piece_made(piece:Node2D)->void:
	_piece_home_pos = piece.position
	var _error := piece.connect("touched", self, "_on_CarrotPiece_touched", [piece])
	assert(_error==OK, "Connection failed with error " + str(_error))
	_pieces[piece] = null


func _on_Carrot_piece_slid(new_home_pos:Vector2, piece:Node2D)->void:
	_pieces[piece] = new_home_pos


func _on_CarrotPiece_touched(piece:Node2D)->void:
	match _state:
		_State.AWAITING_PIECE_TOUCH:
			if piece.is_draggable:
				_current_carrot_piece = piece
				_set_state(_State.DRAGGING_PIECE)


func _animate_CarrotPiece_to_home(duration:float)->void:
	var _tween := Tween.new()
	add_child(_tween)
	# warning-ignore:return_value_discarded
	_tween.connect("tween_completed", self, "_on_CarrotPiece_tween_completed")
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		_current_carrot_piece, "position", 
		_current_carrot_piece.position, _pieces[_current_carrot_piece], duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_CarrotPiece_tween_completed(_a, _b)->void:
	_set_state(_State.AWAITING_PIECE_TOUCH)
	_chunk_return_sound.play()


func _on_Knife_chopped()->void:
	_carrot.split()


func _on_Knife_chop_animation_complete()->void:
	_knife.tappable = false
	_knife.is_glowing = false
	var _next_pos = _carrot.current_chop_point_pos
	
	if _next_pos!=null:
		_animate_Knife_to_next_chop_point(knife_chop_transition_animation_duration)
	else:
		_animate_Knife_to_home()
		#reset carrot
		_carrot.done = false
		# warning-ignore:return_value_discarded
		_carrot.disconnect("touched", self, "_on_Carrot_touched")
		# warning-ignore:return_value_discarded
		_carrot.disconnect("piece_made", self, "_on_Carrot_piece_made")
		# warning-ignore:return_value_discarded
		_carrot.disconnect("piece_slid", self, "_on_Carrot_piece_slid")
		_set_state(_State.AWAITING_PIECE_TOUCH)


func _animate_Knife_to_home()->void:	
	var _tween := Tween.new()
	var _next_pos :Vector2= $KnifeHomePoint.position
	
	add_child(_tween)
	# warning-ignore:return_value_discarded
	_tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		_knife, "position", 
		_knife.position, _next_pos, knife_offscreen_animation_duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	_tween.start()


func _animate_Knife_to_next_chop_point(duration:float)->void:
	var _tween := Tween.new()
	var _next_pos :Vector2= _carrot.position + _carrot.current_chop_point_pos
	
	add_child(_tween)
	# warning-ignore:return_value_discarded
	_tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		_knife, "position", 
		_knife.position, _next_pos, duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	_tween.start()


func _on_Knife_tween_completed(_a, _b)->void:
	_knife.tappable = true
	_knife.is_glowing = true


# warning-ignore:function_conflicts_variable
func _game_over()->void:
	_game_over = true


func _on_HUD_Times_Up()->void:
	_game_over = true
	$ReplayButton.visible = true


func _spawn_carrot(pos:Vector2) -> Node2D:
	_compost_bowl_count = 0
	_done_bowl_count = 0
	_carrot = preload("res://PrepStation/Carrot/Carrot.tscn").instance()
	$Carrots.add_child(_carrot)
	#float there
	_carrot.position = pos
	
	return _carrot


func _check_bowls():
	if (_done_bowl_count == _done_bowl_limit and _compost_bowl_count == _compost_bowl_limit):
		var _new_carrot = _spawn_carrot(_current_carrot_pos)
		$Carrots.move_child(_new_carrot, 0)
		$HUD.update_Carrot_count(1)
		return true


func _on_ReplayButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://PrepStation/PrepStation.tscn")
