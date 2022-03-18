extends Timer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var timer = Timer.new()
var label = Label.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer = get_node("Timer")
	timer.wait_time(3)
	timer.connect("timeout",self,"_on_timer_timeout") 

func _on_start():
	timer.start()
	

func _on_timer_timeout():
	timer.emit_signal("timeout")
	print("Times UP!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
