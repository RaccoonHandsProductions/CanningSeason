extends KinematicBody2D


func _draw():
	draw_rect(
		Rect2($CollisionShape2D.position, $CollisionShape2D.shape.extents), 
		Color.magenta)
	
