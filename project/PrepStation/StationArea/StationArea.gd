extends Area2D

# Emitted when a touch is released in this thing's collision area
signal touch_released


func _on_CompostBowl_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and not event.pressed:
		emit_signal("touch_released")
		
