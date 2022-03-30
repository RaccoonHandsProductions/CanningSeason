extends Control

var ip_address : String

var _current_label_value : String
var _current_field_index := 0
var ip_octet : String
var _focused_field

onready var _fields = [$VBoxContainer/OctetDisplay/OctetField, 
$VBoxContainer/OctetDisplay/OctetField2, 
$VBoxContainer/OctetDisplay/OctetField3, 
$VBoxContainer/OctetDisplay/OctetField4]

onready var back_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/BackButton
onready var next_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/NextButton
onready var number_button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in number_button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
	back_button.disabled = false
	for panel in _fields:
		panel.set_label("0")
	_change_field_selected(_current_field_index)

func validate_octet(oct : String):
	if (int(oct) >= 0 and int(oct) <= 255):
		return true
	else:
		return false

func toggle_number_buttons_disabled(disabled : bool):
	for buttons in number_button_array:
			buttons.disabled = disabled

func finialize_address():
			return(_fields[0].get_label_text() +"."+ _fields[1].get_label_text() +"."+ 
			_fields[2].get_label_text() +"."+ _fields[3].get_label_text())
			
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
		toggle_number_buttons_disabled(true)

func _on_ClearButton_pressed():
	_focused_field.set_label("0")
	ip_octet = ""
	toggle_number_buttons_disabled(false)

func _on_NextButton_pressed():
	if _current_field_index < 3:
		_current_field_index += 1
		_focused_field.has_focus = false
		_change_field_selected(_current_field_index)
		toggle_number_buttons_disabled(false)
	
func on_number_Button_pressed(num):
	var temp = int(_focused_field.get_label_text()) * 10 + num
	if (temp == 0):
		toggle_number_buttons_disabled(true)
	else:
		_focused_field.set_label(str (temp))
		if (_focused_field.get_label_text().length() > 2 or int(_focused_field.get_label_text()) > 25 ):
			toggle_number_buttons_disabled(true)
		
	if (int(_focused_field.get_label_text()) == 25):
		for i in range(5, 9):
			number_button_array[i].disabled = true
	#Updates IP address every change so valid ip is always available
	ip_address = finialize_address()
