extends KinematicBody2D

signal dropped
signal piece_made(next_chop_point_pos)

var _rect_size

var _is_draggable
var _is_being_dragged

var _mouse_pos

var _split_count = 0

# If there is a next chop point, this is its position in my coordinate space.
# If there is not a next chop point, this is null.
onready var current_chop_point_pos = $ChopPoint0.position

func _ready():
	_is_draggable = false
	_rect_size = $CollisionShape2D.shape.extents

func _draw():
	draw_rect(
		Rect2( -(_rect_size), 2*(_rect_size) ), 
		Color.maroon)
	


func _physics_process(_delta):
	if _is_being_dragged:
		_mouse_pos = get_global_mouse_position()
		self.global_position = Vector2(_mouse_pos.x, _mouse_pos.y)
	


func _on_Carrot_input_event(_viewport, event, _shape_idx):
	if _is_draggable:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				_is_being_dragged = event.pressed
				if event.pressed == false:
					emit_signal("dropped")

		elif event is InputEventScreenTouch:
			if event.pressed and event.get_index() == 0:
				self.position = event.get_position()


func _input(_event):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT and not _event.pressed:
			_is_being_dragged = false


func split() -> void:
	_split_count += 1
	match (_split_count): 
		1:
			$CarrotPiece0.position.x -= 30
			$CarrotPiece0._split()
			$CarrotPiece0._is_frond = true
		2:
			$CarrotPiece1.position.x -= 25
			$CarrotPiece1._split()
		3:
			$CarrotPiece2.position.x -= 20
			$CarrotPiece2._split()
		4:
			$CarrotPiece3.position.x -= 15
			$CarrotPiece3._split()
			$CarrotPiece4._split()
		5: 
			assert(false, "Split was invoked more times than possible")
	emit_signal("piece_made", get_next_Chop_Point_pos())

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
	
	
	
	







