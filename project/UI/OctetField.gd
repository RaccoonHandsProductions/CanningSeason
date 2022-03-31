extends Panel

const NumbersAllowed = preload("res://UI/NumbersAllowed.gd")

const _unfocused_background := Color.black
const _focused_background := Color.orange

var _style := StyleBoxFlat.new()
var _value := 0

export var has_focus := false setget _set_has_focus

func _ready():
	add_stylebox_override("panel", _style)
	_update_background()


func _set_has_focus(value:bool)->void:
	has_focus = value
	_update_background()


func _update_background()->void:
	_style.set_bg_color(_focused_background if has_focus else _unfocused_background)
	update()


func enter_value(digit:int):
	_value = _value * 10 + digit
	$Label.text = str(_value)
	
	
func get_allowable_digits():
	if _value < 25:
		return NumbersAllowed.ALL
	elif _value == 25:
		return NumbersAllowed.ZERO_TO_FIVE
	else:
		return NumbersAllowed.NONE


func clear():
	_value = 0
	$Label.text = "0"	


func get_value()->int:
	return _value
