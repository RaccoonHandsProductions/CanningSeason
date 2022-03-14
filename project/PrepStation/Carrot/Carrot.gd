extends KinematicBody2D

signal dropped

var _rect_size

var _is_draggable
var _is_being_dragged

var _mouse_pos


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
	print("hello 2")
	$CarrotPiece.position.x -= 30
	$CarrotPiece._split()

