extends Control

var entered_address : String

var octet_0_entry : String
var octet_1_entry : String
var octet_2_entry : String
var octet_3_entry : String

onready var button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in button_array:
		button.connect("pressed", $VBoxContainer/OctetDisplay, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
			

func finialize_address(octet_0:String, octet_1:String, 
	octet_2:String, octet_3:String):
		return(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)

