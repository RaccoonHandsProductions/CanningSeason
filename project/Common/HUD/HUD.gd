extends CanvasLayer

signal time_out

onready var _carrot_count_label := find_node("CarrotCountLabel")
onready var _sanitized_jar_label := find_node("SanitizedJarLabel")
onready var _filled_jar_label := find_node("FilledJarLabel")


func _ready() -> void:
	# warning-ignore:return_value_discarded
	Stock.connect("chunk_sets_changed", self, "_on_chunk_sets_changed")
	# warning-ignore:return_value_discarded
	Stock.connect("sanitized_jars_changed", self, "_on_sanitized_jars_changed")
	# warning-ignore:return_value_discarded
	Stock.connect("filled_jars_changed", self, "_on_filled_jars_changed")


func _process(_delta):
	$TimeLabel.set_text( "Time: " + str( int( $GameTimer.get_time_left() ) ) )


func show_message(text):
	$Message.text = text


func _on_chunk_sets_changed(count):
	_carrot_count_label.text = (str(count))


func _on_sanitized_jars_changed(count):
	_sanitized_jar_label.text = (str(count))


func _on_filled_jars_changed(count):
	_filled_jar_label.text = (str(count)) 


func _on_MessageTimer_timeout():
	$Message.hide()


func _on_GameTimer_timeout():
	emit_signal("time_out")
