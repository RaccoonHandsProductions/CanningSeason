extends Control

var entered_address : String
var octet_0_entry : String
var octet_1_entry : String
var octet_2_entry : String
var octet_3_entry : String

onready var backButton = get_node("VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/PreviousBoxPriority")
onready var nextButton = get_node("VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/NextBoxPriority")

onready var button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in button_array:
		button.connect("pressed", $VBoxContainer/OctetDisplay, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
			

func finialize_address(octet_0:String, octet_1:String, 
	octet_2:String, octet_3:String):
		return(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)

func _on_OctetDisplay_nextButtonToggle():
	nextButton.disabled = not nextButton.disabled


func _on_OctetDisplay_backButtonToggle():
	backButton.disabled = not backButton.disabled

func _on_NextBoxPriority_pressed():
	if $VBoxContainer/OctetDisplay.current_section_index == 1:
		_on_OctetDisplay_backButtonToggle()
	$VBoxContainer/OctetDisplay.current_section_index += 1
	if $VBoxContainer/OctetDisplay.current_section_index == 3:
		_on_OctetDisplay_nextButtonToggle()
	$VBoxContainer/OctetDisplay.octet_array[$VBoxContainer/OctetDisplay.current_section_index-1].has_focus = false
	$VBoxContainer/OctetDisplay.octet_array[$VBoxContainer/OctetDisplay.current_section_index].has_focus = true
	

func _on_PreviousBoxPriority_pressed():
	if $VBoxContainer/OctetDisplay.current_section_index == 3:
		_on_OctetDisplay_nextButtonToggle()
	$VBoxContainer/OctetDisplay.current_section_index -= 1
	if $VBoxContainer/OctetDisplay.current_section_index == 0:
		_on_OctetDisplay_backButtonToggle()
	$VBoxContainer/OctetDisplay.octet_array[$VBoxContainer/OctetDisplay.current_section_index+1].has_focus = false
	$VBoxContainer/OctetDisplay.octet_array[$VBoxContainer/OctetDisplay.current_section_index].has_focus = true

