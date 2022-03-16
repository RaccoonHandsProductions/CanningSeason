extends Node2D

# The duration of the animation between chop points
export var knife_chop_transition_animation_duration := 0.3
# The duration of the animation of knife from or to home
export var knife_offscreen_animation_duration := .75


export var carrot_float_animation_duration := 0.5
export var piece_float_animation_duration := 0.2

var bowl_count = 0
var bowl_limit = 5

enum _State {
	AWAITING_CARROT_TOUCH,
	DRAGGING_CARROT,
	CARROT_FLOATING_HOME,
	AWAITING_KNIFE_CHOP,
	
	AWAITING_PIECE_TOUCH,
	DRAGGING_PIECE,
	PIECE_FLOATING_HOME,
	ALL_PIECES_PLACED
}

var _state = _State.AWAITING_CARROT_TOUCH
var current_cut_piece :Node2D = null
var piece_home_pos
var _pieces := {} #key = CarrotPiece node, value = CarrotPiece.pos

var _new_bowl_polygon : PoolVector2Array

# Called when the node enters the scene tree for the first time.
func _ready():
	for point in $NewBowl.polygon:
		_new_bowl_polygon.append(point + $NewBowl.position)


func _input(event):
	match _state:
		_State.DRAGGING_CARROT:
				if event is InputEventMouseMotion:
					$Carrot.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var above_board := Geometry.is_point_in_polygon($Carrot.position, $NewCuttingBoard.polygon)
					if above_board:
						_animate_Knife_to_next_chop_point(knife_chop_transition_animation_duration)
						_set_state(_State.AWAITING_KNIFE_CHOP)
					else:
						_set_state(_State.CARROT_FLOATING_HOME)
						var tween := Tween.new()
						add_child(tween)
						# warning-ignore:return_value_discarded
						tween.connect("tween_completed", self, "_set_state_to_awaiting_carrot_touch")
						# warning-ignore:return_value_discarded
						tween.interpolate_property(
							$Carrot, "position", 
							$Carrot.position, $CarrotSpawnPoint.position, 
							carrot_float_animation_duration,
						Tween.TRANS_QUAD, Tween.EASE_IN)
						# warning-ignore:return_value_discarded
						tween.start()
		_State.DRAGGING_PIECE:
			#if statement for if piece is in the bowl to avoid taking it out?
			if event is InputEventMouseMotion:
				current_cut_piece.position += event.relative
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_bowl := Geometry.is_point_in_polygon(
					current_cut_piece.position+$Carrot.position,
					_new_bowl_polygon)
				if above_bowl:
					bowl_count += 1
					print("Bowl Count: " + str(bowl_count))
					if (bowl_count%bowl_limit) == 0:
						_set_state(_State.ALL_PIECES_PLACED)
					else:
						current_cut_piece.done = true
						_set_state(_State.AWAITING_PIECE_TOUCH)
				else:
					_set_state(_State.PIECE_FLOATING_HOME)
					_animate_CarrotPiece_to_home(piece_float_animation_duration)

# Because this is bound to tween_completed, we have to have two arguments
# that are ignored.
func _set_state_to_awaiting_carrot_touch(_a, _b):
	_set_state(_State.AWAITING_CARROT_TOUCH)
	

func _animate_Knife_to_next_chop_point(duration:float):
	var tween := Tween.new()
	var next_pos :Vector2= $Carrot.position + $Carrot.current_chop_point_pos
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, next_pos, duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()


func _on_Knife_tween_completed(_a, _b):
	$Knife.tappable = true
	


func _on_Knife_chopped():
	$Carrot.split()



func _on_Knife_chop_animation_complete():
	$Knife.tappable = false
	var next_pos = $Carrot.current_chop_point_pos
	if next_pos!=null:
		_animate_Knife_to_next_chop_point(knife_chop_transition_animation_duration)
	else:
		_animate_Knife_to_home()
		_set_state(_State.AWAITING_PIECE_TOUCH)


func _animate_Knife_to_home():	
	var tween := Tween.new()
	var next_pos :Vector2= $KnifeOffScreenPos.position
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Knife_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, next_pos, knife_offscreen_animation_duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()
	
	
func _animate_CarrotPiece_to_home(duration:float):
	var tween := Tween.new()
	var next_pos :Vector2= piece_home_pos
	add_child(tween)
	# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_CarrotPiece_tween_completed")
	# warning-ignore:return_value_discarded
	tween.interpolate_property(
		current_cut_piece, "position", 
		current_cut_piece.position, _pieces[current_cut_piece], duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	# warning-ignore:return_value_discarded
	tween.start()
	


func _on_CarrotPiece_tween_completed(_a, _b):
	_set_state(_State.AWAITING_PIECE_TOUCH)


func _set_state(new_state)->void:
	_state = new_state
	match new_state:
		_State.AWAITING_PIECE_TOUCH:
			for piece in _pieces:
				piece.is_draggable = true
		_State.DRAGGING_PIECE:
			for piece in _pieces:
				piece.is_draggable = false


func _on_Carrot_touched():
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_set_state(_State.DRAGGING_CARROT)


func _on_CarrotPiece_touched(piece:Node2D):
	match _state:
		_State.AWAITING_PIECE_TOUCH:
			if piece.is_draggable:
				current_cut_piece = piece
				_set_state(_State.DRAGGING_PIECE)



func _on_Carrot_piece_made(piece:Node2D) -> void:
	piece_home_pos = piece.position
	var error := piece.connect("touched", self, "_on_CarrotPiece_touched", [piece])
	assert(error==OK, "Connection failed with error " + str(error))
	_pieces[piece] = piece.position
