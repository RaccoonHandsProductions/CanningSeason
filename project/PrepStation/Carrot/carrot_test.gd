extends Node2D


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				print("hello")
				$Carrot._split()
				$Carrot.input_pickable = false
