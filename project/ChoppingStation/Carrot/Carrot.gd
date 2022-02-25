extends KinematicBody2D


#Initialize signals to be sent to ChoppingStation.tscn
signal carrot_head_chopped
signal carrot_4_5_chopped
signal carrot_3_5_chopped
signal carrot_2_5_chopped

#variables to set when the carrot can be dragged and when it is being dragged
var _draggable
var _dragging


func _process(_delta):
	#sets the position of the carrot to the cursors position when being dragged
	if _dragging:
		var _mousepos := get_viewport().get_mouse_position()
		self.position = Vector2(_mousepos.x, _mousepos.y)


func _on_Carrot_input_event(_viewport, _event, _shape_idx):
	if _draggable:
		if _event is InputEventMouseButton:
			if _event.button_index == BUTTON_LEFT and _event.pressed:
				#enables dragging when carrot is touched
				_set_dragging()
			elif _event.button_index == BUTTON_LEFT and !_event.pressed:
				#disables dragging when carrot is released
				_set_dragging()
		elif _event is InputEventScreenTouch:
			if _event.pressed and _event.get_index() == 0:
				self.position = _event.get_position()


func _start_chopping()-> void:
	$ChopPoint0.visible = true


func _enable_dragging()-> void:
	_draggable = true
	print("can drag now")


func _disable_dragging()-> void:
	_draggable = false
	print("cant drag now")


func _set_dragging()-> void:
	_dragging=!_dragging


#Detects when the specified area has been touched and sets the animation accordingly.
func _on_ChopPoint0_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("4_5Carrot")
			$ChopPoint0.visible = false
			$ChopPoint1.visible = true
			
			emit_signal("carrot_head_chopped")


func _on_ChopPoint1_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("3_5Carrot")
			$ChopPoint1.visible = false
			$ChopPoint2.visible = true
			
			emit_signal("carrot_4_5_chopped")


func _on_ChopPoint2_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("2_5Carrot")
			$ChopPoint2.visible = false
			$ChopPoint3.visible = true
			
			emit_signal("carrot_3_5_chopped")


func _on_ChopPoint3_input_event(_viewport, _event, _shape_idx):
	if _event is InputEventMouseButton:
		if _event.button_index == BUTTON_LEFT:
			$CarrotPieces.play("1_5Carrot")
			$ChopPoint3.visible = false
			$CarrotPieces.visible = false
			
			emit_signal("carrot_2_5_chopped")
