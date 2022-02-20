extends Control


func _ready():
	$JoinButton.disabled = true
	

func _on_IpAdressEdit_text_changed(_new_text):
	$JoinButton.disabled = false


func _on_HelpButton_pressed():
	$HelpPopup.visible = true


func _on_HideHelpButton_pressed():
	$HelpPopup.visible = false


func _on_JoinButton_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ConnectionSuccessful/ConnectionSuccessful.tscn")
