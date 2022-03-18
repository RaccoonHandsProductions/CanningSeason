extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _carrot_collected = 0
# Called when the node enters the scene tree for the first time.
func _add_carrot_collected():
	_carrot_collected += 1
	return _carrot_collected
	
func _reset_carrots_collected():
	_carrot_collected = 0
	return _carrot_collected

func _num_of_carrots():
	return _carrot_collected
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
