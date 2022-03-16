extends KinematicBody2D


signal piece_made(piece)
signal touched
var done := false

var _rect_size

var _is_draggable
var _is_being_dragged

var _mouse_pos

var _split_count = 0

# If there is a next chop point, this is its position in my coordinate space.
# If there is not a next chop point, this is null.
var current_chop_point_pos

func _ready():
	_is_draggable = false
	_rect_size = $CollisionShape2D.shape.extents
	current_chop_point_pos = $ChopPoint0.position

func _draw():
	draw_rect(
		Rect2( -(_rect_size), 2*(_rect_size) ), 
		Color.maroon)
	


func split() -> void:
	_split_count += 1
	var split_piece
	match (_split_count): 
		1:
			$CarrotPiece0.position.x -= 30
			$CarrotPiece0._split()
			$CarrotPiece0._is_frond = true
			split_piece = $CarrotPiece0
		2:
			$CarrotPiece1.position.x -= 25
			$CarrotPiece1._split()
			split_piece = $CarrotPiece1
		3:
			$CarrotPiece2.position.x -= 20
			$CarrotPiece2._split()
			split_piece = $CarrotPiece2
		4:
			$CarrotPiece3.position.x -= 15
			$CarrotPiece3._split()
			$CarrotPiece4._split()
			split_piece = $CarrotPiece3
			emit_signal("piece_made", split_piece)
			split_piece = $CarrotPiece4
		5: 
			assert(false, "Split was invoked more times than possible")
	# warning-ignore:return_value_discarded
	get_next_Chop_Point_pos()
	emit_signal("piece_made", split_piece)

func get_next_Chop_Point_pos()->Vector2:
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
