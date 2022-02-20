extends Control

func _ready():
	$IpAddressLabel.text = IP.resolve_hostname( str(OS.get_environment("COMPUTERNAME")), 1)


func _on_HelpButton2_pressed():
	$HelpPopup.visible = true


func _on_HideHelpButton_pressed():
	$HelpPopup.visible = false


func _on_Disconnect_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Welcome/Welcome.tscn")
