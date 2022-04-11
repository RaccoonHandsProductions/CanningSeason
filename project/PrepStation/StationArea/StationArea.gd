extends Node2D

#Sizes of areas an object can be dropped in
var polygon_circle_radius := 80
var polygon_rect_length := 180
var polygon_rect_width := 200

var _polygon_points := PoolVector2Array()
var _polygon_color := Color.white
var is_glowing := false setget _set_glowing


func _ready():
	match self.name:
		"CompostBowl", "DoneBowl":
			set_circle_polygon(Vector2.ZERO, polygon_circle_radius)
		"CuttingBoard":
			set_rect_polygon(Vector2.ZERO, 
				polygon_rect_length, polygon_rect_width)
	$Polygon2D.set_color(_polygon_color)


func play_animation(animation_name:String)->void:
	$AnimationPlayer.play(animation_name)


func set_circle_polygon(center:Vector2, radius:int)->void:
	var angle_from = 0
	var angle_to = 360
	#360 degress in a circle
	
	var circle_point_num = 32 
	#determines quality of circle
	
	_polygon_points.push_back(center)
	for i in range(circle_point_num + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / circle_point_num - 90)
		
		_polygon_points.push_back(
			center + Vector2(cos(angle_point), 
			sin(angle_point)) * radius)
	#sets points in a circle pattern in the polygon_points array
	
	$Polygon2D.set_polygon(_polygon_points)


func set_rect_polygon(center:Vector2, length:int, width:int):
	#length = x-axis, width = y-axis
	_polygon_points.push_back(center + Vector2(-length, -width)) #top left
	_polygon_points.push_back(center + Vector2(length, -width)) #top right
	_polygon_points.push_back(center + Vector2(length, width)) #bottom right
	_polygon_points.push_back(center + Vector2(-length, width)) #bottom right
	$Polygon2D.set_polygon(_polygon_points)


func _set_glowing(value:bool)->void:
	is_glowing = value
	$GlowingArea.visible = is_glowing
