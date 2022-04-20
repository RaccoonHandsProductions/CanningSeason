extends CanvasLayer

signal time_out
signal carrot_resource_changed(empty)
signal jar_resource_changed(empty)


onready var _carrot_count_label := find_node("CarrotCountLabel")
onready var _sanitized_jar_label := find_node("SanitizedJarLabel")
onready var _filled_jar_label := find_node("FilledJarLabel")
var _game_over := false


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Stock.connect("chunk_sets_changed", self, "_on_chunk_sets_changed")
	# warning-ignore:return_value_discarded
	Stock.connect("sanitized_jars_changed", self, "_on_sanitized_jars_changed")
	# warning-ignore:return_value_discarded
	Stock.connect("filled_jars_changed", self, "_on_filled_jars_changed")
	
	self.connect("time_out", self, "_on_HUD_Times_Out")
	
	$CarrotGlowingArea.visible = false
	$JarGlowingArea.visible = false


func _process(_delta):
	$TimeLabel.set_text("Time: " + str(int($GameTimer.get_time_left())))
	if _game_over:
		get_tree().change_scene("res://Common/Endgame.tscn")
		get_tree().paused = true


func _game_over()->void:
	_game_over = true

func show_message(text):
	$Message.text = text


func set_alert(type:String, empty:bool):
	match type:
		"carrots":
			if empty:
				$CarrotAlertSound.play()
			else:
				$CarrotAlertSound.stop()
		"jars":
			if empty:
				$JarAlertSound.play()
			else:
				$JarAlertSound.stop()


func _on_chunk_sets_changed(count):
	_carrot_count_label.text = (str(count))
	var empty = null
	if count == 0:
		$CarrotGlowingArea.visible = true # set here so all HUDs glow
		empty = true
	else:
		$CarrotGlowingArea.visible = false
		empty = false
	emit_signal("carrot_resource_changed", empty)


func _on_sanitized_jars_changed(count):
	_sanitized_jar_label.text = (str(count))
	var empty = null
	if count == 0:
		$JarGlowingArea.visible = true # set here so all HUDs glow
		empty = true
	else:
		$JarGlowingArea.visible = false
		empty = false
	emit_signal("jar_resource_changed", empty)


func _on_filled_jars_changed(count):
	_filled_jar_label.text = (str(count)) 


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_GameTimer_timeout():
	emit_signal("time_out")

func _on_HUD_Times_Out()->void:
	_game_over = true
