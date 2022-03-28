extends Control

var entered_address : String
var octet_0_entry : String
var octet_1_entry : String
var octet_2_entry : String
var octet_3_entry : String

var current_section
var current_field_index := 0
var ip_octet : String

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

