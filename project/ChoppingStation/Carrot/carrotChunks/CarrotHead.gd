extends KinematicBody2D


var _draggable
var _dragging


func _process(_delta):
		#sets the position of the carrot head to the cursors position when being dragged
	if _dragging:
		var _mousepos := get_viewport().get_mouse_position()
		self.position = Vector2(_mousepos.x, _mousepos.y)


func _on_CarrotHead_input_event(_viewport, _event, _shape_idx):
	if _draggable:
		if _event is InputEventMouseButton:
			#enables dragging when carrot head is touched
			if _event.button_index == BUTTON_LEFT and _event.pressed:
				_set_dragging()
			#disables dragging when carrot head is released
			elif _event.button_index == BUTTON_LEFT and !_event.pressed:
				_set_dragging()
		elif _event is InputEventScreenTouch:
			if _event.pressed and _event.get_index() == 0:
				self.position = _event.get_position()


func _enableDragging():
	_draggable = true
	print("can drag Carrot Head now")


func _disableDragging():
	_draggable = false
	print("cant drag Carrot Head now")


func _set_dragging():
	_dragging=!_dragging

