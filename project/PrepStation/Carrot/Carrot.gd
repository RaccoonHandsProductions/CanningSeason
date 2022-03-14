extends KinematicBody2D

signal dropped
signal piece_made

var _rect_size

var _is_draggable
var _is_being_dragged

var _mouse_pos

var _count = 0

func _ready():
	_is_draggable = true
	_rect_size = $CollisionShape2D.shape.extents

func _draw():
	draw_rect(
		Rect2( -(_rect_size), 2*(_rect_size) ), 
		Color.maroon)
	


func _physics_process(delta):
	if _is_being_dragged:
		_mouse_pos = get_global_mouse_position()
		self.global_position = Vector2(_mouse_pos.x, _mouse_pos.y)
	

func _on_WholeFood_input_event(_viewport, _event, _shape_idx)->void:
	if _is_draggable:
		if _event is InputEventMouseButton:
			if _event.button_index == BUTTON_LEFT:
				_is_being_dragged = _event.pressed
				if _event.pressed == false:
					emit_signal("dropped")

		elif _event is InputEventScreenTouch:
			if _event.pressed and _event.get_index() == 0:
				self.position = _event.get_position()


func _input(_event):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT and not _event.pressed:
			_is_being_dragged = false


func _split() -> void:
	_count += 1

	if _count == 1:
		$CarrotPiece.position.x -= 30
		$CarrotPiece._split()
		$CarrotPiece._is_frond = true
		emit_signal("piece_made")
	if _count == 2:
		$CarrotPiece2.position.x -= 25
		$CarrotPiece2._split()
		emit_signal("piece_made")
	if _count == 3:
		$CarrotPiece3.position.x -= 20
		$CarrotPiece3._split()
		emit_signal("piece_made")
	if _count == 4:
		$CarrotPiece4.position.x -= 15
		$CarrotPiece4._split()
		$CarrotPiece5._split()
		emit_signal("piece_made")
