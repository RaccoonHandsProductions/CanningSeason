extends KinematicBody2D

signal touched

var is_draggable : bool
var done := false

func _ready():
	is_draggable = true
	
func _on_Jar_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")
