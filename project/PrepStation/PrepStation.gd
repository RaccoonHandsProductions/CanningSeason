extends Node2D

onready var _cutting_board := $NewCuttingBoard

onready var _done_bowl := $NewBowl
var done_bowl_count := 0
var done_bowl_limit := 4
var bowl_full := false

onready var _compost_bowl = $NewCompostBowl
var compost_bowl_count := 0
var compost_bowl_limit := 1
var compost_bowl_full := false

onready var _carrot := $Carrot
export var carrot_float_animation_duration := 0.5
export var carrot_animation_duration := 0.5

var current_cut_piece :Node2D= null
var piece_home_pos : Vector2
var _pieces := {} #key = CarrotPiece node, value = CarrotPiece.pos
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

func _ready():
	#adjusts the points of the Polygon2Ds to match any offset made in the PrepStation scene editor
	for point in _done_bowl.polygon:
		_new_bowl_polygon.append(point + _done_bowl.position)
	for point in _compost_bowl.polygon:
		_new_compost_bowl_polygon.append(point + _compost_bowl.position)

	_set_state(_State.AWAITING_CARROT_TOUCH)


func _process(_delta):
	if _game_over:
		get_tree().paused = true
		$HUD/TimeLabel.text = "GAME OVER"

func _input(event):
	match _state:
		_State.DRAGGING_CARROT:
				if event is InputEventMouseMotion:
					_carrot.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var above_board := Geometry.is_point_in_polygon(_carrot.position, _cutting_board.polygon)
					if above_board:
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
				current_cut_piece.position += event.relative
				current_cut_piece._animation_player.play("RESET")
				$CompostBowl/AnimationPlayer.play("Glow")
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_compost_bowl := Geometry.is_point_in_polygon(
					current_cut_piece.position + _carrot.position,
					_new_compost_bowl_polygon)
			
				if current_cut_piece._is_frond:
					if above_compost_bowl:
						current_cut_piece.done = true
						compost_bowl_count += 1
						print("Compost Bowl Count: " + str(compost_bowl_count))

						if (compost_bowl_count%compost_bowl_limit) == 0:
							_set_state(_State.AWAITING_PIECE_TOUCH)
						else:
							_set_state(_State.AWAITING_FROND_TOUCH)
							
					else:
						_set_state(_State.PIECE_FLOATING_HOME)
						_animate_CarrotPiece_to_home(piece_float_animation_duration)
						_set_state(_State.AWAITING_FROND_TOUCH)
						
		
		_State.DRAGGING_PIECE:
			#if statement for if piece is in the bowl to avoid taking it out?
			if event is InputEventMouseMotion:
				current_cut_piece.position += event.relative
				current_cut_piece._animation_player.play("RESET")
				$DoneBowl/AnimationPlayer.play("Glow")
			elif event is InputEventMouseButton and not event.is_pressed():
				var above_bowl := Geometry.is_point_in_polygon(
					current_cut_piece.position+_carrot.position,
					_new_bowl_polygon)
					
				if not current_cut_piece._is_frond:
					if above_bowl:
						done_bowl_count += 1
						if (done_bowl_count % 4 == 0 and done_bowl_count != 0):
							$HUD.update_score(1)
						print("Bowl Count: " + str(done_bowl_count))
						current_cut_piece.done = true
						if (done_bowl_count%done_bowl_limit) == 0:
							$DoneBowl/AnimationPlayer.play("RESET")
							_carrot = preload("res://PrepStation/Carrot/Carrot.tscn").instance()
							add_child(_carrot)
							#float there
							_carrot.position = $CarrotHomePoint.position
							_set_state(_State.AWAITING_CARROT_TOUCH)
						else:
							_set_state(_State.AWAITING_PIECE_TOUCH)
							current_cut_piece._animation_player.play("RESET")
							# warning-ignore:return_value_discarded
							_pieces.erase(current_cut_piece)
					else:
						if not current_cut_piece.done:
							_set_state(_State.PIECE_FLOATING_HOME)
							_animate_CarrotPiece_to_home(piece_float_animation_duration)
					

# Because this is bound to tween_completed, we have to have two arguments
# that are ignored.
func _set_state_to_awaiting_carrot_touch(_a, _b)->void:
	_set_state(_State.AWAITING_CARROT_TOUCH)
	

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
	


func _on_Knife_chopped()->void:
	_carrot.split()



func _on_Knife_chop_animation_complete()->void:
	_knife.tappable = false
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
	
	
func _animate_CarrotPiece_to_home(duration:float)->void:
	var tween := Tween.new()
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
	


func _on_CarrotPiece_tween_completed(_a, _b)->void:
	if current_cut_piece._is_frond:
		_set_state(_State.AWAITING_FROND_TOUCH)
	else:
		_set_state(_State.AWAITING_PIECE_TOUCH)


func _set_state(new_state)->void:
	_state = new_state
	match new_state:
		_State.AWAITING_CARROT_TOUCH:
			for piece in _pieces:
				piece._animation_player.play("RESET")
			_pieces.clear()
			# warning-ignore:return_value_discarded
			_carrot.connect("touched", self, "_on_Carrot_touched")
			# warning-ignore:return_value_discarded
			_carrot.connect("piece_made", self, "_on_Carrot_piece_made")
		_State.AWAITING_PIECE_TOUCH:
			$CompostBowl/AnimationPlayer.play("RESET")
			for piece in _pieces:
				piece._animation_player.play("Glow")
				if piece._is_frond:
					piece._animation_player.play("RESET")
				$DoneBowl/AnimationPlayer.play("RESET")
				piece.is_draggable = true
		_State.DRAGGING_PIECE:
			for piece in _pieces:
				piece.is_draggable = false
		_State.AWAITING_FROND_TOUCH:
			for piece in _pieces:
				if piece._is_frond:
					piece._animation_player.play("Glow")
					$CompostBowl/AnimationPlayer.play("RESET")
					piece.is_draggable = true
		_State.DRAGGING_FROND:
			for piece in _pieces:
				piece.is_draggable = false


func _on_Carrot_touched()->void:
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_set_state(_State.DRAGGING_CARROT)


func _on_CarrotPiece_touched(piece:Node2D)->void:
	match _state:
		_State.AWAITING_PIECE_TOUCH:
			if piece.is_draggable:
				current_cut_piece = piece
				_set_state(_State.DRAGGING_PIECE)
		_State.AWAITING_FROND_TOUCH:
			if piece.is_draggable:
				current_cut_piece = piece
				_set_state(_State.DRAGGING_FROND)



func _on_Carrot_piece_made(piece:Node2D)->void:
	piece_home_pos = piece.position
	var error := piece.connect("touched", self, "_on_CarrotPiece_touched", [piece])
	assert(error==OK, "Connection failed with error " + str(error))
	_pieces[piece] = piece.position

# warning-ignore:function_conflicts_variable
func _game_over()->void:
	_game_over = true


func _on_HUD_Times_Up()->void:
	_game_over = true
