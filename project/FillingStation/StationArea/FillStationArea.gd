extends Node2D


var polygon_circle_radius := 80
var _done_area_length := 100
var _done_area_width := 80

var _polygon_points := PoolVector2Array()
var _polygon_color := Color.white
var is_glowing := false setget _set_glowing



func _ready():
	set_rect_polygon(Vector2(14, 0), _done_area_length, _done_area_width)
	$Polygon2D.set_color(_polygon_color)


func set_rect_polygon(center:Vector2, length:int, width:int):
	#length = x-axis, width = y-axis
	_polygon_points.push_back(center + Vector2(-length, -width)) #top left
	_polygon_points.push_back(center + Vector2(length, -width)) #top right
	_polygon_points.push_back(center + Vector2(length, width)) #bottom right
	_polygon_points.push_back(center + Vector2(-length, width)) #bottom right
	$Polygon2D.set_polygon(_polygon_points)


func get_polygon()->Node:
	return $Polygon2D

func get_polygon_points()->Array:
	return $Polygon2D.polygon

func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing
