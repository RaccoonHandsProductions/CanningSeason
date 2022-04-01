extends Node2D

onready var _cutting_board_polygon_2d := $CuttingBoard/Polygon2D
onready var _frond = null
onready var _cutting_board := $CuttingBoard

onready var _chunk_drop_sound := $ChunkDropSound
onready var _carrot_drop_sound := $CarrotDropSound
onready var _chunk_return_sound := $ChunkReturnSound

onready var _done_bowl_polygon_2d = $DoneBowl/Polygon2D
onready var _done_bowl := $DoneBowl
var done_bowl_count := 0
var done_bowl_limit := 4
var bowl_full := false

onready var _compost_bowl_polygon_2d = $CompostBowl/Polygon2D
onready var _compost_bowl := $CompostBowl
var compost_bowl_count := 0
var compost_bowl_limit := 1
var compost_bowl_full := false

var _carrot : Node2D
export var carrot_float_animation_duration := 0.5
export var carrot_animation_duration := 0.5

var current_carrot_piece :Node2D= null
var piece_home_pos : Vector2
#key = CarrotPiece node, value = CarrotPiece.pos
var _pieces := {} 
export var piece_float_animation_duration := 0.2

onready var _knife = $Knife
# The duration of the animation between chop points
export var knife_chop_transition_animation_duration := 0.3
# The duration of the animation of knife from or to home
export var knife_offscreen_animation_duration := .75


var _state = null
enum _State {
	AWAITING_CARROT_TOUCH,
	DRAGGING_CARROT,
	CARROT_FLOATING_HOME,
	AWAITING_KNIFE_CHOP,
	AWAITING_PIECE_TOUCH,
	DRAGGING_PIECE,
	PIECE_FLOATING_HOME,
}
var _game_over := false


var _new_bowl_polygon : PoolVector2Array
var _new_compost_bowl_polygon : PoolVector2Array
var _new_cutting_board_polygon : PoolVector2Array

var _carrot_spawn_positions := [Vector2(617,88), Vector2(597, 155), Vector2(640, 209), Vector2(666, 105), Vector2(666, 172), Vector2(685, 132)]
var _carrots
var _carrot_count := 1
var _current_carrot_pos : Vector2

var piece_node_location

func _ready():
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


func _process(_delta):
	if _game_over:
		get_tree().paused = true
		$HUD/TimeLabel.text = "GAME OVER"


func _input(event):
	match _state:
		_State.DRAGGING_CARROT:
			
			_cutting_board.is_glowing = true
			if _carrot.is_draggable:
				if event is InputEventMouseMotion:
					_carrot.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var above_board := Geometry.is_point_in_polygon(
						_carrot.position, _new_cutting_board_polygon)
					if above_board:
						_carrot_count += 1
						_carrot_drop_sound.play()
						$Carrots.move_child(_carrot, _carrots.size() - 1)
						_animate_Knife_to_next_chop_point(knife_offscreen_animation_duration)
						_carrot.done = true
						_set_state(_State.AWAITING_KNIFE_CHOP)
						
					else:
						_set_state(_State.CARROT_FLOATING_HOME)
						var tween := Tween.new()
						add_child(tween)
						# warning-ignore:return_value_discarded
						tween.connect("tween_completed", self, "_set_state_to_awaiting_carrot_touch")
						# warning-ignore:return_value_discarded
						tween.interpolate_property(
							_carrot, "position", 
							_carrot.position, $CarrotHomePoint.position, 
							carrot_float_animation_duration,
						Tween.TRANS_QUAD, Tween.EASE_IN)
						# warning-ignore:return_value_discarded
						tween.start()
			
		_State.DRAGGING_PIECE:
			#if statement for if piece is in the bowl to avoid taking it out?
			if event is InputEventMouseMotion:
				current_carrot_piece.position += event.relative
				_carrot.move_child(current_carrot_piece, _carrot.get_child_count() - 1)
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_compost_bowl := Geometry.is_point_in_polygon(
					current_carrot_piece.position + _carrot.position,
					_new_compost_bowl_polygon)
			
				if current_carrot_piece.is_frond:
					print(piece_node_location)
					if above_compost_bowl:
						_chunk_drop_sound.play()
						current_carrot_piece.rotation = rand_range(0,360)
						current_carrot_piece.done = true
						compost_bowl_count += 1
						print("Compost Bowl Count: " + str(compost_bowl_count))

						if _check_bowls():
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
							
					else:
						_set_state(_State.PIECE_FLOATING_HOME) # -------------------------- THIS IS NOT A 'REAL' STATE
						_carrot.move_child(current_carrot_piece, piece_node_location)
						_animate_CarrotPiece_to_home(piece_float_animation_duration)
						_set_state(_State.AWAITING_PIECE_TOUCH)
								
				var above_done_bowl := Geometry.is_point_in_polygon(
					current_carrot_piece.position+_carrot.position,
					_new_bowl_polygon)
					
				if not current_carrot_piece.is_frond:
					if above_done_bowl:
						_chunk_drop_sound.play()
						current_carrot_piece.rotation = rand_range(0,360)
						done_bowl_count += 1
						print("Bowl Count: " + str(done_bowl_count))
						current_carrot_piece.done = true
						if _check_bowls():
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
							# warning-ignore:return_value_discarded
							_pieces.erase(current_carrot_piece)
					else:
						if not current_carrot_piece.done:
							_carrot.move_child(current_carrot_piece, piece_node_location)
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
					
					var error := _carrot.connect("piece_slid", self, "_on_Carrot_piece_slid")
					assert(error==OK, "Connection failed with error " + str(error))
			
		_State.AWAITING_PIECE_TOUCH:
			for piece in _pieces:
				if not piece.done:
					piece.is_glowing = true
				piece.is_draggable = true
				
		_State.DRAGGING_PIECE:
			piece_node_location = current_carrot_piece.get_index()
			if current_carrot_piece.is_frond:
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
	piece_home_pos = piece.position
	var error := piece.connect("touched", self, "_on_CarrotPiece_touched", [piece])
	assert(error==OK, "Connection failed with error " + str(error))
	_pieces[piece] = null


func _on_Carrot_piece_slid(new_home_pos:Vector2, piece:Node2D)->void:
	_pieces[piece] = new_home_pos


func _on_CarrotPiece_touched(piece:Node2D)->void:
	match _state:
		_State.AWAITING_PIECE_TOUCH:
			if piece.is_draggable:
				current_carrot_piece = piece
				_set_state(_State.DRAGGING_PIECE)


func _animate_CarrotPiece_to_home(duration:float)->void:
	var tween := Tween.new()
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_CarrotPiece_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		current_carrot_piece, "position", 
		current_carrot_piece.position, _pieces[current_carrot_piece], duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()


func _on_CarrotPiece_tween_completed(_a, _b)->void:
	_set_state(_State.AWAITING_PIECE_TOUCH)
	_chunk_return_sound.play()
		
		
func _on_Knife_chopped()->void:
	_carrot.split()


func _on_Knife_chop_animation_complete()->void:
	_knife.tappable = false
	_knife.is_glowing = false
	var next_pos = _carrot.current_chop_point_pos
	if next_pos!=null:
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
	var tween := Tween.new()
	var next_pos :Vector2= $KnifeHomePoint.position
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		_knife, "position", 
		_knife.position, next_pos, knife_offscreen_animation_duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()


func _animate_Knife_to_next_chop_point(duration:float)->void:
	var tween := Tween.new()
	var next_pos :Vector2= _carrot.position + _carrot.current_chop_point_pos
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		_knife, "position", 
		_knife.position, next_pos, duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()


func _on_Knife_tween_completed(_a, _b)->void:
	_knife.tappable = true
	_knife.is_glowing = true


# warning-ignore:function_conflicts_variable
func _game_over()->void:
	_game_over = true


func _on_HUD_Times_Up()->void:
	_game_over = true
	

func _spawn_carrot(pos) -> Node2D:
	compost_bowl_count = 0
	done_bowl_count = 0

	_carrot = preload("res://PrepStation/Carrot/Carrot.tscn").instance()
	$Carrots.add_child(_carrot)
	
	#float there
	_carrot.position = pos
	
	return _carrot

func _check_bowls():
	if (done_bowl_count == done_bowl_limit and compost_bowl_count == compost_bowl_limit):
		var new_carrot = _spawn_carrot(_current_carrot_pos)
		$Carrots.move_child(new_carrot, 0)
		$HUD.update_score(1)
		return true



