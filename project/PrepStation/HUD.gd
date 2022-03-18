extends CanvasLayer

# Displays time left on timer as a string from an integer from the timer, in the TimeLabel
func _process(delta):
	$TimeLabel.set_text( "Time Left: " + str( int( $GameTimer.get_time_left() ) ) )

# sets the Message label to a text value input for contexual HUD messages / testing states
func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

# sets the ScoreLabel based on a variable input
func update_score(score):
	$ScoreLabel.text = ( "Score: " + str(score) )


func _on_MessageTimer_timeout():
	$Message.hide()
