extends Control

onready var _carrot := $Carrot
onready var _carrot_global_pos = $Carrot.position

func _ready():
	$Knife.position = _carrot_global_pos + $Carrot/ChopPoint0.position

func _on_SplitButton_pressed():
	_carrot.split()


func _on_Carrot_piece_made(next_chop_point_pos):
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		$Knife, "position", 
		$Knife.position, (next_chop_point_pos + _carrot_global_pos), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	tween.start()
