extends KinematicBody2D

var _draggable
var _dragging

func _process(_delta):
	if _dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _on_CarrotChunkMiddle_input_event(_viewport, _event, _shape_idx):
	if _draggable:
		if _event is InputEventMouseButton:
			if _event.button_index == BUTTON_LEFT and _event.pressed:
				_set_dragging()
			elif _event.button_index == BUTTON_LEFT and !_event.pressed:
				_set_dragging()
		elif _event is InputEventScreenTouch:
			if _event.pressed and _event.get_index() == 0:
				self.position = _event.get_position()

func _enableDragging():
	_draggable = true
	print("can drag Carrot Chunk Middle now")

func _disableDragging():
	_draggable = false
	print("cant drag Carrot Chunk Middle now")
	
func _set_dragging():
	_dragging=!_dragging


