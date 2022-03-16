extends KinematicBody2D

signal dropped

var _rect_size

var _is_draggable
var _is_being_dragged

var _is_frond = false

var _mouse_pos

func _ready():
	_is_draggable = true
	_rect_size = $CollisionShape2D.shape.extents

func _draw():
	#Rect2(Vector2(-36, -36), Vector2(72, 72)
	draw_rect(
		Rect2( -(_rect_size), 2*(_rect_size) ), 
		Color.magenta)

func _physics_process(_delta):
	if _is_being_dragged:
		_mouse_pos = get_global_mouse_position()
		self.global_position = Vector2(_mouse_pos.x, _mouse_pos.y)


func _split() ->void:
	input_pickable = true


func _on_CarrotPiece_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("touched")
