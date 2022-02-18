extends KinematicBody2D

var _draggable
var _dragging

func _process(_delta):
	if _dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = Vector2(mousepos.x, mousepos.y)

func _on_Carrot_input_event(_viewport, event, _shape_idx):
	if _draggable:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				_set_dragging()
			elif event.button_index == BUTTON_LEFT and !event.pressed:
				_set_dragging()
		elif event is InputEventScreenTouch:
			if event.pressed and event.get_index() == 0:
				self.position = event.get_position()
		


func _enableDragging():
	_draggable = true
	print("can drag now")

func _disableDragging():
	_draggable = false
	print("cant drag now")
	
func _set_dragging():
	_dragging=!_dragging
	
