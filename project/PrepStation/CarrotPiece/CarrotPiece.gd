extends KinematicBody2D

signal touched

var _rect_size : Vector2

var is_frond := false

onready var animation_player := $AnimationPlayer
onready var is_draggable := false
onready var done := false

func _ready():
	_rect_size = $CollisionShape2D.shape.extents


func split() ->void:
	input_pickable = true


func play_animation(animation_name:String):
	animation_player.play(animation_name)

func _on_CarrotPiece_input_event(_viewport, event, _shape_idx):
	if not done:
		if event is InputEventMouseButton and event.pressed:
			emit_signal("touched")
			



