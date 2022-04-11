
extends CanvasLayer

signal Times_Up

# Displays time left on timer as a string from an integer from the timer, in the TimeLabel
func _process(_delta):
	update_Carrot_count(0)
	update_Clean_Jar_count(0)
	update_Full_Jar_count(0)
	$TimeLabel.set_text( "Time: " + str( int( $GameTimer.get_time_left() ) ) )

# sets the Message label to a text value input for contexual HUD messages / testing states
func show_message(text):
	$Message.text = text
	#$Message.show()		# Uncomment this to show state messages
	#$MessageTimer.start()	# This removes state messages after a short period

# sets the ScoreLabel based on a variable input
var count = 0
func update_Carrot_count(carrotPiece):
	if (carrotPiece != 100):
		count += carrotPiece
	else:
		count = 0;
	$ScoreLabel.text = ( "Score: " + str(count) )
	
var cleanCount = 0
func update_Clean_Jar_count(cleanJar):
	if (cleanJar != 100):
		cleanCount += cleanJar
	else:
		cleanCount = 0;
	$CleanJarLabel.text = ( "Clean Jars: " + str(cleanCount) )
	
var fullCount = 0
func update_Full_Jar_count(fullJar):
	if (fullJar != 100):
		fullCount += fullJar
	else:
		fullCount = 0;
	$FullJarLabel.text = ( "Full Jars: " + str(fullCount) )
	
# Hides message on MesageTimer timeout
func _on_MessageTimer_timeout():
	$Message.hide()


func _on_GameTimer_timeout():
	emit_signal("Times_Up")
