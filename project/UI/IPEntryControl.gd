extends Control

var entered_address : String
var octet_0_entry : String
var octet_1_entry : String
var octet_2_entry : String
var octet_3_entry : String

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
onready var enter_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/EnterButton
onready var number_button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in number_button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
	back_button.disabled = false
	_change_field_selected(current_field_index)

func validate_octet(oct : String):
	if (int(oct) >= 0 and int(oct) <= 255):
		return true
	else:
		return false

func toggle_number_buttons_disabled(disabled : bool):
	for buttons in number_button_array:
			buttons.disabled = disabled

func finialize_address(octet_0 : String, octet_1 : String, 
	octet_2 : String, octet_3 : String):
			return(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)
			
func _update_field_selected(ip_input : String):
	pass
	
func _change_field_selected(num : int):
	priority_field = _fields[num]
	priority_field.has_focus = true
	
func _on_PreviousBoxPriority_pressed():
	current_field_index -= 1
	_change_field_selected(current_field_index)

func _on_ClearBox_pressed():
	pass

func _on_NextBoxPriority_pressed():
	priority_field.set_label(current_label_value)
	_update_field_selected(ip_octet)
	current_field_index += 1
	_change_field_selected(current_field_index)

func _on_EnterButton_pressed():
	pass # Replace with function body.
	
func on_number_Button_pressed(num):
	if str(num).length() <= 2:
		ip_octet += str(num)
