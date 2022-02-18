extends Node2D

enum GameState{
	DRAGGING,
	CHOPPING,
	SORTING
}

# Initialized in _ready
var _state
var entered = false

func _ready():
	_enter_state(GameState.DRAGGING)
	
func _physics_process(delta):
	if entered == true && $Carrot._dragging == false && _state == GameState.DRAGGING:
		_enter_state(GameState.CHOPPING)


func _enter_state(new_state)->void:
	# Handle the logic for leaving the old state
	match _state:
		GameState.DRAGGING:
			print('Leaving the dragging state')
			$Carrot._disableDragging()
	
	# Assign the state to the new state
	_state = new_state
	
	# Handle the logic for entering the new state
	match new_state:
		GameState.DRAGGING:
			# Activate the top carrot (or spawn one in for now, or something)
			print('Entering the DRAGGING state')
			$Carrot._enableDragging()

		GameState.CHOPPING:
			# Here we would move the knife into position
			print('Entering the CHOPPING state')


func _on_CuttingBoard_body_entered(body):
	entered = true


func _on_CuttingBoard_body_exited(body):
	 entered = false
