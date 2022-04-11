extends CanvasLayer

signal Times_Up

var _carrot_count = 0
var _clean_count = 0
var _full_count = 0
# Displays time left on timer as a string from an integer from the timer, in the TimeLabel
func _process(_delta):
	$TimeLabel.set_text( "Time: " + str( int( $GameTimer.get_time_left() ) ) )

# sets the Message label to a text value input for contexual HUD messages / testing states
func show_message(text):
	$Message.text = text
	#$Message.show()		# Uncomment this to show state messages
	#$MessageTimer.start()	# This removes state messages after a short period

# sets the ScoreLabel based on a variable input
# Carrot counter should signal the server 
# and will update carrot_count with a +1 if carrot chop completed, -1 if jar completed.
func increment_Carrot_count():
	_carrot_count += 1
	$ScoreLabel.text = ( "Score: " + str(_carrot_count) )
	
# Sanitized Jar counter should signal 
# the server and update Sanitized Jar Count by +1, -1 if jar completed.
func increment_Clean_Jar_count():
	_clean_count += 1
	$CleanJarLabel.text = ( "Clean Jars: " + str(_clean_count) )
	
func increment_Full_Jar_count():
	_full_count += 1
	$FullJarLabel.text = ( "Full Jars: " + str(_full_count) )

func decrement_Carrot_count():
	_carrot_count -= 1
	$ScoreLabel.text = ( "Score: " + str(_carrot_count) )
	
func decrement_Clean_Jar_count():
	_clean_count -= 1
	$CleanJarLabel.text = ( "Clean Jars: " + str(_clean_count) )
	
# Hides message on MesageTimer timeout
func _on_MessageTimer_timeout():
	$Message.hide()


func _on_GameTimer_timeout():
	emit_signal("Times_Up")
