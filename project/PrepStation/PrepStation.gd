extends Node2D

# The duration of the animation between chop points
export var knife_chop_transition_animation_duration := 0.3

# The duration of the animation of knife from or to home
export var knife_offscreen_animation_duration := .75

# Called when the node enters the scene tree for the first time.
func _ready():
	_animate_Knife_to_next_chop_point(knife_offscreen_animation_duration)
	


func _animate_Knife_to_next_chop_point(duration:float):
	var tween := Tween.new()
	var next_pos :Vector2= $Carrot.position + $Carrot.current_chop_point_pos
	add_child(tween)
# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Tween_tween_completed")
# warning-ignore:return_value_discarded
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, next_pos, duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()


func _on_Tween_tween_completed(_a, _b):
	$Knife.tappable = true
	


func _on_Knife_chopped():
	$Carrot.split()



func _on_Knife_chop_animation_complete():
	$Knife.tappable = false
	var next_pos = $Carrot.current_chop_point_pos
	if next_pos!=null:
		_animate_Knife_to_next_chop_point(knife_chop_transition_animation_duration)
	else:
		_animate_Knife_to_home()

func _animate_Knife_to_home():	
	var tween := Tween.new()
	var next_pos :Vector2= $KnifeOffScreenPos.position
	add_child(tween)
# warning-ignore:return_value_discarded
	tween.connect("tween_completed", self, "_on_Tween_tween_completed")
# warning-ignore:return_value_discarded
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, next_pos, knife_offscreen_animation_duration,
		Tween.TRANS_QUAD, Tween.EASE_IN)
# warning-ignore:return_value_discarded
	tween.start()
	
	
	




