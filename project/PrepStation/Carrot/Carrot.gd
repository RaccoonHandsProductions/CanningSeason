extends KinematicBody2D


signal piece_made(piece)
signal piece_slid(new_home_pos, piece)
signal touched

# If there is a next chop point, this is its position in my coordinate space.
# If there is not a next chop point, this is null.
var current_chop_point_pos
var done := false
var is_draggable : bool
var is_glowing := false setget _set_glowing
var _split_count := 0

onready var tween := $Tween


func _ready():
	is_draggable = false
	current_chop_point_pos = $ChopPoint0.position


func move_chunk_x(chunk, amount):
		tween.interpolate_property(chunk, "position:x",
			chunk.position.x, chunk.position.x+amount, .025,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()


func split() -> void:
	_split_count += 1
	var current_piece = null
	var gap_size = 0
	
	match (_split_count): 
		1:
			current_piece = $CarrotPiece0
			gap_size = -52
			current_piece.is_frond = true
		2:
			current_piece = $CarrotPiece1
			gap_size = -38
		3:
			current_piece = $CarrotPiece2
			gap_size = -24
		4:
			current_piece = $CarrotPiece3
			gap_size = -10
			move_chunk_x(current_piece, gap_size)
			current_piece.split()
			emit_signal("piece_made", current_piece)
			current_piece = $CarrotPiece4
			gap_size = 0
		5: 
			assert(false, "Split was invoked more times than possible")
			
	move_chunk_x(current_piece, gap_size)
	current_piece.split()
	emit_signal("piece_made", current_piece)
	# warning-ignore:return_value_discarded
	_get_next_Chop_Point_pos()


func _get_next_Chop_Point_pos()->Vector2:
	match (_split_count):
		1:
			current_chop_point_pos = $ChopPoint1.position
		2:
			current_chop_point_pos = $ChopPoint2.position
		3:
			current_chop_point_pos = $ChopPoint3.position
		4:
			current_chop_point_pos = null
		_:
			assert(false, "Should never get here")
	return(current_chop_point_pos)


func _on_Carrot_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")


func _on_Tween_tween_completed(object, _key):
	emit_signal("piece_slid", object.position, object)
	if object == $CarrotPiece3:
		emit_signal("piece_slid", $CarrotPiece4.position, $CarrotPiece4)


func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing
