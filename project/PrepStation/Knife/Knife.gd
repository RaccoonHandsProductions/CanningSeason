extends Node2D

# This signal is emitted when the knife strikes the table.
# This is not the end of the animation, but it is the point at which
# it has "cut through" whatever is under it.
signal chopped
signal chop_animation_complete

export var debug_color := Color.whitesmoke

# Indicates if the knife can be tapped to initiate the chop animation
export var tappable := false setget _set_tappable

onready var _animation_player := $AnimationPlayer
onready var _chop_sound := $ChopSound

func _set_tappable(value:bool)->void:
	tappable = value
	if tappable:
		_animation_player.play("Glow")
	else:
		_animation_player.play("RESET")
		_animation_player.stop()


func _emit_chopped_signal():
	emit_signal("chopped")


func _on_Knife_input_event(_viewport, event, _shape_idx):
	if tappable and not _is_playing_chop_animation():
		if event is InputEventMouseButton and event.is_pressed():
			_animation_player.play("Chop")
			_chop_sound.play()


func _is_playing_chop_animation()->bool:
	return _animation_player.current_animation == "Chop"


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Chop":
		emit_signal("chop_animation_complete")
