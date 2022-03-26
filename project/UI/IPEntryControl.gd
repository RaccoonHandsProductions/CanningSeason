extends Control

var entered_address : String
var octet_0_entry : String
var octet_1_entry : String
var octet_2_entry : String
var octet_3_entry : String

var current_section 
var current_section_label
var current_field_index := 1
var ip_octet : String
var ip_array = []


onready var field_one = get_node("VBoxContainer/OctetDisplay/OctetField")
onready var field_two = get_node("VBoxContainer/OctetDisplay/OctetField2")
onready var field_three = get_node("VBoxContainer/OctetDisplay/OctetField3")
onready var field_four = get_node("VBoxContainer/OctetDisplay/OctetField4")

onready var field_one_label = get_node("VBoxContainer/OctetDisplay/OctetField/Label")
onready var field_two_label = get_node("VBoxContainer/OctetDisplay/OctetField2/Label")
onready var field_three_label = get_node("VBoxContainer/OctetDisplay/OctetField3/Label")
onready var field_four_label = get_node("VBoxContainer/OctetDisplay/OctetField4/Label")

onready var OctetDisplay = get_node("VBoxContainer/OctetDisplay")
onready var backButton = get_node("VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/PreviousBoxPriority")
onready var nextButton = get_node("VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/NextBoxPriority")
onready var button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
	_choose_Display_field(current_field_index)
			
func finialize_address(octet_0:String, octet_1:String, 
	octet_2:String, octet_3:String):

		var octet_array = [int(octet_0), int(octet_1), int(octet_2), int(octet_3)]
		for octet in octet_array:
			if octet < 0 or octet > 255:
				assert(false, "your IP does not exist")
			else:
				print(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)
				return(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)

func on_number_Button_pressed(num:int):
		if ip_octet.length() < 3:
			ip_octet += str(num) #creates octet string
			current_section_label.text += str(num)
		elif ip_octet.length() == 3:
			ip_array.append(ip_octet)
			ip_octet = ""
			current_field_index += 1
			_choose_Display_field(current_field_index)
		
		if ip_array.size() == 4 :
			for buttons in button_array:
				buttons.disabled = true
				
		update()
	
func _choose_Display_field(field):
	match field:
		1:
			current_section = field_one
			current_field_index = 1
			current_section_label = field_one_label
			current_section.has_focus = true
			field_two.has_focus = false
			field_three.has_focus = false
			field_four.has_focus = false 
			backButton.disabled = true
			update()
		2:
			current_section = field_two
			current_field_index = 2
			current_section_label = field_two_label
			field_one.has_focus = false
			current_section.has_focus = true
			field_three.has_focus = false
			field_four.has_focus = false
			backButton.disabled = false
			nextButton.disabled = false
			update()
		3:
			current_section = field_three
			current_field_index = 3
			current_section_label = field_three_label
			field_one.has_focus = false
			field_two.has_focus = false
			current_section.has_focus = true
			field_four.has_focus = false
			backButton.disabled = false
			nextButton.disabled = false
			update()
		4:
			current_section = field_four
			current_field_index = 4
			current_section_label = field_four_label
			field_one.has_focus = false
			field_two.has_focus = false
			field_three.has_focus = false
			current_section.has_focus = true
			backButton.disabled = false
			nextButton.disabled = true
			update()

func _on_NextBoxPriority_pressed():
	current_field_index += 1
	_choose_Display_field(current_field_index)
	ip_array.append(ip_octet)
	ip_octet = ""
		

func _on_PreviousBoxPriority_pressed():
	ip_array.pop_at(ip_array.length()-1)
	current_section_label.text = ""
	if button_array[2].disabled == true:
		for buttons in button_array:
				buttons.disabled = false
	current_field_index -= 1
	_choose_Display_field(current_field_index)
	ip_array.append(ip_octet)
	ip_octet = ""


func _on_ClearBox_pressed():
	ip_array.clear()
	field_one_label.text = ""
	field_two_label.text = ""
	field_three_label.text = ""
	field_four_label.text = ""
	ip_octet = ""
	current_field_index = 1
	
	for buttons in button_array:
		buttons.disabled = false
	nextButton.disabled = false
	_choose_Display_field(current_field_index)


func _on_enterButton_pressed():
	finialize_address(ip_array.pop_front(), ip_array.pop_front(), ip_array.pop_front(), ip_array.pop_front())
	#close scene and use ip
