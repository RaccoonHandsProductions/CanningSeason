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
	


func _process(_delta):
	if _is_being_dragged:
		_mouse_pos = get_viewport().get_mouse_position()
		self.position = Vector2(_mouse_pos.x, _mouse_pos.y)
		
	


func _set_is_being_dragged()->void:
	_is_being_dragged = !(_is_being_dragged)
	

func _on_WholeFood_input_event(_viewport, _event, _shape_idx)->void:
	if _is_draggable:
		if _event is InputEventMouseButton:
			if _event.button_index == BUTTON_LEFT and _event.pressed:
				#enables dragging when carrot is touched
				_set_is_being_dragged()
				
			
			elif _event.button_index == BUTTON_LEFT and !(_event.pressed):
				#disables dragging when carrot is released
				_set_is_being_dragged()
				emit_signal("dropped")
				
			
		elif _event is InputEventScreenTouch:
			if _event.pressed and _event.get_index() == 0:
				self.position = _event.get_position()

func _split() -> void:
	print("hello 2")
	$CarrotPiece.position.x -= 30
	$CarrotPiece._split()

