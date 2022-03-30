extends Control

var ip_address : String

var current_label_value : String
var current_field_index := 0
var ip_octet : String
var priority_field

onready var _fields = [$VBoxContainer/OctetDisplay/OctetField, 
$VBoxContainer/OctetDisplay/OctetField2, 
$VBoxContainer/OctetDisplay/OctetField3, 
$VBoxContainer/OctetDisplay/OctetField4]

onready var back_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/PreviousBoxPriority
onready var next_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/UserBoxPosition/NextBoxPriority
onready var number_button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in number_button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
	back_button.disabled = false
	for panel in _fields:
		panel.set_label("0")
	_change_field_selected(current_field_index)

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
	priority_field.set_label(ip_input)
	
func _change_field_selected(num : int):
	if num >= 0 and num <=3:
		priority_field = _fields[num]
		priority_field.has_focus = true
	
func _on_PreviousBoxPriority_pressed():
	if current_field_index > 0:
		current_field_index -= 1
		priority_field.has_focus = false
		_change_field_selected(current_field_index)
		toggle_number_buttons_disabled(false)

func _on_ClearBox_pressed():
	priority_field.set_label("")
	ip_octet = ""

func _on_NextBoxPriority_pressed():
	if current_field_index < 3:
		current_field_index += 1
		priority_field.has_focus = false
		_change_field_selected(current_field_index)
		toggle_number_buttons_disabled(false)

func _on_EnterButton_pressed():
	ip_address = finialize_address()
	print(ip_address)
	
func on_number_Button_pressed(num):
	if ip_octet.length() <= 2:
		ip_octet += str(num)
		if validate_octet(ip_octet):
			_update_field_label(ip_octet)
		else:
			ip_octet = ""
			ip_octet += str(num)
			_on_NextBoxPriority_pressed()
			_update_field_label(ip_octet)
	else:
		ip_octet = ""
		ip_octet += str(num)
		_on_NextBoxPriority_pressed()
		_update_field_label(ip_octet)
