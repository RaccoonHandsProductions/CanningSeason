extends Node2D

# The duration of the animation between chop points
export var knife_chop_transition_animation_duration := 0.3
# The duration of the animation of knife from or to home
export var knife_offscreen_animation_duration := .75


export var carrot_float_animation_duration := 0.5



enum _State {
	AWAITING_CARROT_TOUCH,
	DRAGGING_CARROT,
	CARROT_FLOATING_HOME,
	AWAITING_KNIFE_CHOP,
	
}

var _state = _State.AWAITING_CARROT_TOUCH


# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _input(event):
	match _state:
		_State.DRAGGING_CARROT:
				if event is InputEventMouseMotion:
					$Carrot.position += event.relative
				elif event is InputEventMouseButton and not event.is_pressed():
					var above_board := Geometry.is_point_in_polygon($Carrot.position, $NewCuttingBoard.polygon)
					if above_board:
						_animate_Knife_to_next_chop_point(knife_chop_transition_animation_duration)
						_set_state(_State.AWAITING_KNIFE_CHOP)
					else:
						_set_state(_State.CARROT_FLOATING_HOME)
						var tween := Tween.new()
						add_child(tween)
						# warning-ignore:return_value_discarded
						tween.connect("tween_completed", self, "_set_state_to_awaiting_carrot_touch")
						# warning-ignore:return_value_discarded
						tween.interpolate_property(
							$Carrot, "position", 
							$Carrot.position, $CarrotSpawnPoint.position, 
							carrot_float_animation_duration,
						Tween.TRANS_QUAD, Tween.EASE_IN)
						# warning-ignore:return_value_discarded
						tween.start()
			

# Because this is bound to tween_completed, we have to have two arguments
# that are ignored.
func _set_state_to_awaiting_carrot_touch(_a, _b):
	_set_state(_State.AWAITING_CARROT_TOUCH)
	

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
	
	
	

func _set_state(new_state)->void:
	_state = new_state


func _on_Carrot_touched():
	match _state:
		_State.AWAITING_CARROT_TOUCH:
			_set_state(_State.DRAGGING_CARROT)


