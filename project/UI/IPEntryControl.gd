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

onready var field_one = $VBoxContainer/OctetDisplay/OctetField
onready var field_two = $VBoxContainer/OctetDisplay/OctetField2
onready var field_three = $VBoxContainer/OctetDisplay/OctetField3
onready var field_four = $VBoxContainer/OctetDisplay/OctetField4

onready var back_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/PreviousBoxPriority
onready var next_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/userBoxPosition/NextBoxPriority
onready var enter_button = $VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/EnterButton
onready var number_button_array = get_tree().get_nodes_in_group("number_buttons")

func _ready():
	for button in number_button_array:
		button.connect("pressed", self, "on_number_Button_pressed", 
			[ int( button.name.substr(5) ) ])
	_choose_display_field(current_field_index)

func validate_octet(oct : String):
	if (int(oct) >= 0 and int(oct) <= 255):
		return true
	else:
		return false

func finialize_address(octet_0 : String, octet_1 : String, 
	octet_2 : String, octet_3 : String):

		var octet_array = [int(octet_0), int(octet_1), int(octet_2), int(octet_3)]
		for octet in octet_array:
			if octet < 0 or octet > 255:
				assert(false, "your IP does not exist")
			else:
				return(octet_0 +"."+ octet_1 +"."+ octet_2 +"."+ octet_3)

func on_number_Button_pressed(num:int):
	if ip_octet.length() <= 2:
		ip_octet += str(num) #creates octet string
		current_section_label.text += str(num)
	elif ip_octet.length() == 3:
		if validate_octet(ip_octet) == true:
			ip_array.append(ip_octet)
			ip_octet = ""
			for buttons in number_button_array:
				buttons.disabled = true
			if current_section == field_four:
				enter_button.disabled = false
			update()
		else:
			ip_octet = ""
			current_section_label.text = ""
			
			_choose_display_field(current_field_index)
	
	print(ip_array)

func _choose_display_field(field):
	match field:
		1:
			current_section = field_one
			current_field_index = 1
			current_section_label = field_one.get_node("Label")
			current_section.has_focus = true
			field_two.has_focus = false
			field_three.has_focus = false
			field_four.has_focus = false 
			back_button.disabled = true
			enter_button.disabled = true
			update()
		2:
			current_section = field_two
			current_field_index = 2
			current_section_label = field_two.get_node("Label")
			field_one.has_focus = false
			current_section.has_focus = true
			field_three.has_focus = false
			field_four.has_focus = false
			back_button.disabled = false
			next_button.disabled = false
			update()
		3:
			current_section = field_three
			current_field_index = 3
			current_section_label = field_three.get_node("Label")
			field_one.has_focus = false
			field_two.has_focus = false
			current_section.has_focus = true
			field_four.has_focus = false
			back_button.disabled = false
			next_button.disabled = false
			update()
		4:
			current_section = field_four
			current_field_index = 4
			current_section_label = field_four.get_node("Label")
			field_one.has_focus = false
			field_two.has_focus = false
			field_three.has_focus = false
			current_section.has_focus = true
			back_button.disabled = false
			next_button.disabled = true
			update()

func _on_NextBoxPriority_pressed():
	for buttons in number_button_array:
		buttons.disabled = false
	ip_octet = ""
	current_field_index += 1
	_choose_display_field(current_field_index)

func _on_PreviousBoxPriority_pressed():
	ip_array.pop_back()
	current_section_label.text = ""
	current_field_index -= 1
	_choose_display_field(current_field_index)
	ip_array.pop_back()
	current_section_label.text = ""
	if number_button_array[2].disabled == true:
		for buttons in number_button_array:
				buttons.disabled = false
	print(ip_array)

func _on_ClearBox_pressed():
	ip_array.clear()
	field_one.get_node("Label").text = ""
	field_two.get_node("Label").text = ""
	field_three.get_node("Label").text = ""
	field_four.get_node("Label").text = ""
	ip_octet = ""
	current_field_index = 1
	
	for buttons in number_button_array:
		buttons.disabled = false
	next_button.disabled = false
	_choose_display_field(current_field_index)

func _on_EnterButton_pressed():
	ip_array.append(ip_octet)
	ip_octet = ""
	if ip_array.size() == 4 or (ip_array.size() == 5 and ip_array[4] == ""):
		var output = finialize_address(ip_array.pop_front(), ip_array.pop_front(), ip_array.pop_front(), ip_array.pop_front())
		print(output)
		assert(false, "IP is complete: " + output)
	else:
		assert(false, "IP is not complete")
	#close scene and use ip
