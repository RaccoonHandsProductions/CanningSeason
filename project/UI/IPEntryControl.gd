extends Control

const NumbersAllowed = preload("res://UI/NumbersAllowed.gd")

var _current_label_value : String
var _current_field_index := 0
var ip_octet : String
var _focused_field

var ip_address := "" setget , _get_ip_address

onready var _fields = [$VBoxContainer/OctetDisplay/OctetField, 
$VBoxContainer/OctetDisplay/OctetField2, 
$VBoxContainer/OctetDisplay/OctetField3, 
$VBoxContainer/OctetDisplay/OctetField4]

onready var back_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/BackButton
onready var next_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/NextButton
var number_button_array = []

func _ready():
	back_button.disabled = false
	_change_field_selected(_current_field_index)
	number_button_array.append($VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/Button0)
	for number_button in $VBoxContainer/HBoxContainer2/VBoxContainer2/numPad.get_children():
		number_button_array.append(number_button)
	for button in number_button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])

func validate_octet(oct : String):
	if (int(oct) >= 0 and int(oct) <= 255):
		return true
	else:
		return false


func _update_field_label(ip_input : String):
	_focused_field.mutate_label(ip_input)
	
	
func _change_field_selected(num : int):
	if num >= 0 and num <=3:
		_focused_field = _fields[num]
		_focused_field.has_focus = true
	
	
func _on_BackButton_pressed():
	if _current_field_index > 0:
		_current_field_index -= 1
		_focused_field.has_focus = false
		_change_field_selected(_current_field_index)
		_update_allowed_numbers()


func _on_ClearButton_pressed():
	_focused_field.clear()
	ip_octet = ""
	_update_allowed_numbers()


func _on_NextButton_pressed():
	if _current_field_index < 3:
		_current_field_index += 1
		_focused_field.has_focus = false
		_change_field_selected(_current_field_index)
		_update_allowed_numbers()


func on_number_Button_pressed(num:int)->void:
	_focused_field.enter_value(num)
	_update_allowed_numbers()
#
#
#	var temp = int(_focused_field.get_label_text()) * 10 + num
#	if (temp == 0):
#		toggle_number_buttons_disabled(true)
#	else:
#		_focused_field.set_label(str (temp))
#		if (_focused_field.get_label_text().length() > 2 or int(_focused_field.get_label_text()) > 25 ):
#			toggle_number_buttons_disabled(true)
#
#	if (int(_focused_field.get_label_text()) == 25):
#		for i in range(5, 9):
#			number_button_array[i].disabled = true
#	#Updates IP address every change so valid ip is always available
#	ip_address = finialize_address()


func _update_allowed_numbers()->void:
	var allowable = _focused_field.get_allowable_digits()
	for i in number_button_array.size():
		if allowable == NumbersAllowed.NONE:
			number_button_array[i].disabled = true
		elif allowable == NumbersAllowed.ZERO_TO_FIVE:
			number_button_array[i].disabled = i > 4
		else:
			number_button_array[i].disabled = false

func _get_ip_address()->String:
	var result = ""
	for i in _fields.size():
		result += str(_fields[i].get_value())
		if i < _fields.size()-1:
			result += "."
	return result
