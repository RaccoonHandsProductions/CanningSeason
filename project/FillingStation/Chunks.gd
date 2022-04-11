extends KinematicBody2D


signal touched

var done := false
var is_draggable : bool
var is_glowing := false setget _set_glowing


func _ready():
	is_draggable = true


func _on_Chunks_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")

func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing
