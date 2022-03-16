extends KinematicBody2D

signal touched

var _rect_size

var is_draggable := false

var _is_frond = false

var _mouse_pos

func _ready():
	is_draggable = false
	_rect_size = $CollisionShape2D.shape.extents

func _draw():
	#Rect2(Vector2(-36, -36), Vector2(72, 72)
	draw_rect(
		Rect2( -(_rect_size), 2*(_rect_size) ), 
		Color.magenta)


func _split() ->void:
	input_pickable = true


func _on_CarrotPiece_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("touched")
