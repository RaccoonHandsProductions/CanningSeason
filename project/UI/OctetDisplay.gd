extends HBoxContainer



var current_section : Label
var ip_octet : String
var ip_array = []
var current_text_index := -1
var current_section_index := 0
var current_index := 0

onready var octet_array = [$OctetSection0, $OctetSection1, 
$OctetSection2, $OctetSection3]

func _ready():
	current_section = octet_array[0]
	
func on_ip_complete(ip_array : Array):
	for octet in ip_array:
		var octet_num = int(octet)
		if octet_num < 0 or octet_num > 255:
			assert(false, "your IP does not exist")
		else:
			print(ip_array)

func on_number_Button_pressed(num:int):
	ip_octet += str(num)
	current_text_index += 1
	match current_text_index:
		0:
			current_section.text += str(num)
			current_index += 1
		1:
			current_section.text += str(num)
			current_index += 1
		2: 
			current_section.text += str(num)
			current_index += 1
			current_text_index = -1
			ip_array.append(ip_octet)
			if current_index < 12:
				current_section_index += 1
				ip_octet = ""
			elif current_index == 12:
				on_ip_complete(ip_array)
				return ip_array
	
	if current_section_index > 3:
		assert(false, "next section is out of bounds")
	else:
		current_section = octet_array[current_section_index]

