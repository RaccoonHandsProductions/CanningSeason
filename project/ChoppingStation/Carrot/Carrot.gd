extends KinematicBody2D

signal _CarrotHeadChopped
signal _CarrotTipChopped



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

func _startChopping():
	$ChopPoint0.visible = true

func _enableDragging():
	_draggable = true
	print("can drag now")

func _disableDragging():
	_draggable = false
	print("cant drag now")
	
func _set_dragging():
	_dragging=!_dragging
	


func _on_ChopPoint0_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("HeadlessCarrot")
			$ChopPoint0.visible = false
			$ChopPoint1.visible = true
			
			emit_signal("_CarrotHeadChopped")



func _on_ChopPoint1_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("CarrotMiddle")
			$ChopPoint1.visible = false
			
			emit_signal("_CarrotTipChopped")
