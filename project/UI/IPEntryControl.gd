extends Control

signal button_clicked

const _NumbersAllowed = preload("res://UI/NumbersAllowed.gd")

## This is the current IP address entered in this widget.
## It will always be a valid IP address (as a string)
var ip_address := "" setget , _get_ip_address

var _current_field_index := 0
var _focused_field
var _number_buttons = []

onready var _fields = [
	$VBoxContainer/OctetDisplay/OctetField, 
	$VBoxContainer/OctetDisplay/OctetField2, 
	$VBoxContainer/OctetDisplay/OctetField3, 
	$VBoxContainer/OctetDisplay/OctetField4
]
onready var _back_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/BackButton
onready var _next_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/NextButton
onready var _numpad = $VBoxContainer/HBoxContainer2/VBoxContainer2/NumPad
onready var _button0 = $VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/Button0


func _ready():
	_back_button.disabled = false
	_change_field_selected(_current_field_index)
	_set_up_number_buttons()


func _set_up_number_buttons()->void:
	#_button0 is added first to keep the correct order in _number_buttons
	_number_buttons.append(_button0) 
	for number_button in _numpad.get_children():
		_number_buttons.append(number_button)
	for i in _number_buttons.size():
		_number_buttons[i].connect("pressed", self, "on_number_Button_pressed", [i])


func _change_field_selected(num:int)->void:
	assert(num >= 0 and num <= 3, "Unexpected field index %d" % num)
	
	_back_button.disabled = num == 0
	_next_button.disabled = num == 3
	
	if _focused_field:
		_focused_field.has_focus = false
	_focused_field = _fields[num]
	_focused_field.has_focus = true


func _on_BackButton_pressed()->void:
	$ButtonClick.play()
	assert(_current_field_index > 0)
	_current_field_index -= 1
	_change_field_selected(_current_field_index)
	_update_allowed_numbers()


func _on_ClearButton_pressed()->void:
	$ButtonClick.play()
	_focused_field.clear()
	_update_allowed_numbers()


func _on_NextButton_pressed()->void:
	$ButtonClick.play()
	assert(_current_field_index < 3)
	_current_field_index += 1
	_change_field_selected(_current_field_index)
	_update_allowed_numbers()


func on_number_Button_pressed(num:int)->void:
	$ButtonClick.play()
	emit_signal("button_clicked")
	_focused_field.enter_value(num)
	_update_allowed_numbers()


func _update_allowed_numbers()->void:
	var allowable = _focused_field.get_allowable_digits()
	for i in _number_buttons.size():
		if allowable == _NumbersAllowed.NONE:
			_number_buttons[i].disabled = true
		elif allowable == _NumbersAllowed.ZERO_TO_FIVE:
			_number_buttons[i].disabled = i > 5
		else:
			_number_buttons[i].disabled = false


func _get_ip_address()->String:
	var result = ""
	for i in _fields.size():
		result += str(_fields[i].get_value())
		if i < _fields.size()-1:
			result += "."
	return result
