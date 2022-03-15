extends Node2D




# Called when the node enters the scene tree for the first time.
func _ready():
	_animate_Knife_to_next_chop_point()
	


func _animate_Knife_to_next_chop_point():
	var tween := Tween.new()
	var next_pos :Vector2= $Carrot.position + $Carrot.current_chop_point_pos
	add_child(tween)
# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Tween_tween_completed")
# warning-ignore:return_value_discarded
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, next_pos, 1,
		Tween.TRANS_QUAD, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()


func _on_Tween_tween_completed(_a, _b):
	$Knife.tappable = true
	


func _on_Knife_chopped():
	$Carrot.split()



func _on_Knife_chop_animation_complete():
	$Knife.tappable = false
	_animate_Knife_to_next_chop_point()
