extends CanvasLayer

signal Times_Up

var _carrotCount = -1
var _cleanCount = -1
var _fullCount = -10
# Displays time left on timer as a string from an integer from the timer, in the TimeLabel
func _process(_delta):
	increment_Carrot_count()
	increment_Clean_Jar_count()
	increment_Full_Jar_count()
	$TimeLabel.set_text( "Time: " + str( int( $GameTimer.get_time_left() ) ) )

# sets the Message label to a text value input for contexual HUD messages / testing states
func show_message(text):
	$Message.text = text
	#$Message.show()		# Uncomment this to show state messages
	#$MessageTimer.start()	# This removes state messages after a short period

# sets the ScoreLabel based on a variable input

func increment_Carrot_count():
	_carrotCount += 1
	$ScoreLabel.text = ( "Score: " + str(_carrotCount) )
	
func increment_Clean_Jar_count():
	_cleanCount += 1
	$CleanJarLabel.text = ( "Clean Jars: " + str(_cleanCount) )
	
func increment_Full_Jar_count():
	_fullCount += 10
	$CleanJarLabel.text = ( "Clean Jars: " + str(_fullCount) )

func decrement_Carrot_count():
	_carrotCount -= 1
	$ScoreLabel.text = ( "Score: " + str(_carrotCount) )
	
func decrement_Clean_Jar_count():
	_cleanCount -= 1
	$CleanJarLabel.text = ( "Clean Jars: " + str(_cleanCount) )
	
# Hides message on MesageTimer timeout
func _on_MessageTimer_timeout():
	$Message.hide()


func _on_GameTimer_timeout():
	emit_signal("Times_Up")
