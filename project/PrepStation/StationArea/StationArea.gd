extends Node2D

export var polygon_circle_radius := 100
var polygon_points := PoolVector2Array()
var polygon_color := Color.white

func _ready():
	match self.name:
		"CompostBowl", "DoneBowl":
			set_circle_polygon(self.position, polygon_circle_radius)
		"CuttingBoard":
			pass;
	$Polygon2D.set_color(polygon_color)

func set_circle_polygon(center, radius)->void:
	var angle_from = 0
	var angle_to = 360
	#360 degress in a circle
	
	var circle_point_num = 32 
	#determines quality of circle
	
	polygon_points.push_back(center)
	for i in range(circle_point_num + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / circle_point_num - 90)
		
		polygon_points.push_back(
			center + Vector2(cos(angle_point), 
			sin(angle_point)) * radius)
	#sets points in a circle pattern in the polygon_points array
	
	$Polygon2D.set_polygon(polygon_points)
	

func play_animation(animation_name:String)->void:
	$AnimationPlayer.play(animation_name)



