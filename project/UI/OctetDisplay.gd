extends HBoxContainer



var current_section : Label
var current_text_index := -1
var current_section_index := 0

onready var octet_array = [$OctetSection0, $OctetSection1, 
$OctetSection2, $OctetSection3]

func _ready():
	current_section = octet_array[0]

func on_number_Button_pressed(num:int):
	print( str( num ) )
	
	current_text_index += 1
	match current_text_index:
		0:
			current_section.text += str(num)
		1:
			current_section.text += str(num)
		2: 
			current_section.text += str(num)
			current_text_index = -1
			current_section_index += 1
	
	if current_section_index >= 4:
		assert(false, "next section is out of bounds")
	else:
		current_section = octet_array[current_section_index]

