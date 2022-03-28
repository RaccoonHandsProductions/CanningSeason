extends Node2D

onready var _cutting_board_polygon_2d := $CuttingBoard/Polygon2D
onready var _frond = null
onready var _cutting_board := $CuttingBoard

onready var _chunk_drop_sound := $ChunkDropSound
onready var _carrot_drop_sound := $CarrotDropSound
onready var _carrot_pickup_sound := $CarrotPickupSound
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

onready var _carrot := $Carrot
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
	AWAITING_FROND_TOUCH,
	DRAGGING_PIECE,
	DRAGGING_FROND,
	PIECE_FLOATING_HOME,
	ALL_PIECES_PLACED
}
var _game_over := false


var _new_bowl_polygon : PoolVector2Array
var _new_compost_bowl_polygon : PoolVector2Array
var _new_cutting_board_polygon : PoolVector2Array

func _ready():
	#adjusts the points of the Polygon2Ds to match any offset made in the PrepStation scene editor
	for point in _done_bowl_polygon_2d.polygon:
		_new_bowl_polygon.append(point + _done_bowl_polygon_2d.global_position)
	for point in _compost_bowl_polygon_2d.polygon:
		_new_compost_bowl_polygon.append(point + _compost_bowl_polygon_2d.global_position)
	for point in _cutting_board_polygon_2d.polygon:
		_new_cutting_board_polygon.append(point + _cutting_board_polygon_2d.global_position)
	
	_set_state(_State.AWAITING_CARROT_TOUCH)


func _process(_delta):
	if _game_over:
		get_tree().paused = true
		$HUD/TimeLabel.text = "GAME OVER"

func _input(event):
	match _state:
		_State.DRAGGING_CARROT:
			_cutting_board.is_glowing = true
			if event is InputEventMouseMotion:
				_carrot.position += event.relative
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_board := Geometry.is_point_in_polygon(
					_carrot.position, _new_cutting_board_polygon)
				if above_board:
					_carrot_drop_sound.play()
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
		

		_State.DRAGGING_FROND:
			if event is InputEventMouseMotion:
				current_carrot_piece.position += event.relative
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_compost_bowl := Geometry.is_point_in_polygon(
					current_carrot_piece.position + _carrot.position,
					_new_compost_bowl_polygon)
			
				if current_carrot_piece.is_frond:
					if above_compost_bowl:
						_chunk_drop_sound.play()
						current_carrot_piece.done = true
						compost_bowl_count += 1
						print("Compost Bowl Count: " + str(compost_bowl_count))

						if (compost_bowl_count%compost_bowl_limit) == 0:
							_set_state(_State.AWAITING_PIECE_TOUCH)
						else:
							_set_state(_State.AWAITING_FROND_TOUCH)
							
					else:
						_set_state(_State.PIECE_FLOATING_HOME) # -------------------------- THIS IS NOT A 'REAL' STATE
						_animate_CarrotPiece_to_home(piece_float_animation_duration)
						_set_state(_State.AWAITING_FROND_TOUCH)
						
		
		_State.DRAGGING_PIECE:
			#if statement for if piece is in the bowl to avoid taking it out?
			if event is InputEventMouseMotion:
				current_carrot_piece.position += event.relative
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_done_bowl := Geometry.is_point_in_polygon(
					current_carrot_piece.position+_carrot.position,
					_new_bowl_polygon)
					
				if not current_carrot_piece.is_frond:
					if above_done_bowl:
						_chunk_drop_sound.play()
						done_bowl_count += 1
						if (done_bowl_count % 4 == 0 and done_bowl_count != 0):
							$HUD.update_score(1)
						print("Bowl Count: " + str(done_bowl_count))
						current_carrot_piece.done = true
						if (done_bowl_count%done_bowl_limit) == 0:
							
							#reset carrot
							_carrot.done = false
							# warning-ignore:return_value_discarded
							_carrot.disconnect("touched", self, "_on_Carrot_touched")
							# warning-ignore:return_value_discarded
							_carrot.disconnect("piece_made", self, "_on_Carrot_piece_made")
							_carrot = preload("res://PrepStation/Carrot/Carrot.tscn").instance()
							add_child(_carrot)
							
							#float there
							_carrot.position = $CarrotHomePoint.position
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
							# warning-ignore:return_value_discarded
							_pieces.erase(current_carrot_piece)
					else:
						if not current_carrot_piece.done:
							_set_state(_State.PIECE_FLOATING_HOME)
							_animate_CarrotPiece_to_home(piece_float_animation_duration)
					

func _set_state(new_state)->void:
	# Handle logic when leaving state
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_carrot.is_glowing = false
		_State.DRAGGING_CARROT:
			_cutting_board.is_glowing = false
		_State.DRAGGING_FROND:
			_compost_bowl.is_glowing = false
		_State.DRAGGING_PIECE:
			_done_bowl.is_glowing = false
			
	# Update variable
	_state = new_state
	
	#entering state
	match new_state:
		_State.AWAITING_CARROT_TOUCH:
			_carrot.is_glowing = true
			_pieces.clear()
			
			_carrot.done = false
			if not _carrot.is_connected("touched", self, "_on_Carrot_touched"): # or not _carrot.is_connected("piece_made", self, "_on_Carrot_piece_made"):
				# warning-ignore:return_value_discarded
				_carrot.connect("touched", self, "_on_Carrot_touched")
				# warning-ignore:return_value_discarded
				_carrot.connect("piece_made", self, "_on_Carrot_piece_made")
			
		_State.AWAITING_PIECE_TOUCH:
			for piece in _pieces:
				if not piece.done:
					piece.is_glowing = true
				piece.is_draggable = true
		_State.DRAGGING_PIECE:
			_done_bowl.is_glowing = true
			for piece in _pieces:
				piece.is_draggable = false
				piece.is_glowing = false
		_State.AWAITING_FROND_TOUCH:
			for piece in _pieces:
				if piece.is_frond:
					piece.is_glowing = true
					piece.is_draggable = true
		_State.DRAGGING_FROND:
			_compost_bowl.is_glowing = true
			current_carrot_piece.is_glowing = false
			for piece in _pieces:
				piece.is_draggable = false


# Because this is bound to tween_completed, we have to have two arguments
# that are ignored.
func _set_state_to_awaiting_carrot_touch(_a, _b)->void:
	_carrot_pickup_sound.play()
	_set_state(_State.AWAITING_CARROT_TOUCH)
	

func _on_Carrot_touched()->void:
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_carrot_pickup_sound.play()
			_set_state(_State.DRAGGING_CARROT)


func _on_Carrot_piece_made(piece:Node2D)->void:
	piece_home_pos = piece.position
	var error := piece.connect("touched", self, "_on_CarrotPiece_touched", [piece])
	assert(error==OK, "Connection failed with error " + str(error))
	_pieces[piece] = piece.position


func _on_CarrotPiece_touched(piece:Node2D)->void:
	match _state:
		_State.AWAITING_PIECE_TOUCH:
			if piece.is_draggable:
				current_carrot_piece = piece
				_set_state(_State.DRAGGING_PIECE)
		_State.AWAITING_FROND_TOUCH:
			if piece.is_draggable:
				current_carrot_piece = piece
				_set_state(_State.DRAGGING_FROND)


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
	if current_carrot_piece.is_frond:
		_set_state(_State.AWAITING_FROND_TOUCH)
	else:
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
		_set_state(_State.AWAITING_FROND_TOUCH)


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




