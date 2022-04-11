extends KinematicBody2D

signal touched

var is_draggable : bool
var done := false
var is_sanitized := false 
var is_glowing := false setget _set_glowing

func _ready():
	is_draggable = true


func set_sprite(view:String)->void:
	$AnimatedSprite.play(view)


func _on_Jar_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")


func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing
