extends Node2D

func _on_TouchableArea_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		$AnimationPlayer.play("Chop")
