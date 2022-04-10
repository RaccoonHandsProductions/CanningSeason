extends Node2D


#Sizes of objects in JarSanitizationStation
var done_area_length := 200
var done_area_width := 156

#set to inner rect
var stovetop_length := 205
var stovetop_width := 255

var _polygon_points := PoolVector2Array()
var _polygon_color := Color.white

func _ready():
	match self.name:
		"DoneArea":
			set_rect_polygon(Vector2.ZERO, done_area_width, done_area_length)
		"StoveTop":
			set_rect_polygon(Vector2.ZERO, stovetop_width, stovetop_length)
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

