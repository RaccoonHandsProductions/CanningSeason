extends CanvasLayer

# Displays time left on timer as a string from an integer from the timer, in the TimeLabel
func _process(delta):
	update_score(0)
	$TimeLabel.set_text( "Time: " + str( int( $GameTimer.get_time_left() ) ) )

# sets the Message label to a text value input for contexual HUD messages / testing states
func show_message(text):
	$Message.text = text
	#$Message.show()		# Uncomment this to show state messages
	#$MessageTimer.start()	# This removes state messages after a short period

# sets the ScoreLabel based on a variable input
var score = 0
func update_score(carrotPiece):
	if (carrotPiece != 100):
		score += carrotPiece
	else:
		score = 0;
	$ScoreLabel.text = ( "Score: " + str(score) )

# Hides message on MesageTimer timeout
func _on_MessageTimer_timeout():
	$Message.hide()
