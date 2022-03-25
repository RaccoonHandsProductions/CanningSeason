extends KinematicBody2D

signal touched

var _rect_size : Vector2

var is_frond := false
var is_glowing := false setget _set_glowing

onready var is_draggable := false
onready var done := false

func _ready():
	_rect_size = $CollisionShape2D.shape.extents


func split() ->void:
	input_pickable = true


func _on_CarrotPiece_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")
			

func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing

