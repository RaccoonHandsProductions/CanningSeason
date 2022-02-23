extends Node2D

# Called when the knife hits the cutting board
signal chopped

# Can the knife currently be tapped for chopping
export var can_chop := false

var _is_chopping := false


func _on_TouchableArea_input_event(_viewport, event, _shape_idx):
	if can_chop and not _is_chopping:
		if event is InputEventMouseButton and event.pressed:
			_is_chopping = true
			$AnimationPlayer.play("Chop")


func _on_hit_table():
	emit_signal("chopped")


func _on_AnimationPlayer_animation_finished(_anim_name):
	_is_chopping = false
