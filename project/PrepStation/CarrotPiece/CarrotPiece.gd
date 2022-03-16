extends KinematicBody2D

signal dropped

var _rect_size

var _is_draggable
var _is_being_dragged

var is_frond = false

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


func _on_FoodChunk_input_event(_viewport, event, _shape_idx)->void:
	if _is_draggable:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				_is_being_dragged = event.pressed
				if event.pressed == false:
					emit_signal("dropped")
					if is_frond:
						print("dropped the frond")

		elif event is InputEventScreenTouch:
			if event.pressed and event.get_index() == 0:
				self.position = event.get_position()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			_is_being_dragged = false


func split() ->void:
	input_pickable = true
