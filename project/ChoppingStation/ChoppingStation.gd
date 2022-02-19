extends Node2D

enum GameState{
	DRAGGING,
	CHOPPING,
	SORTING
}

onready var _carrotHead = load("res://ChoppingStation/Carrot/carrotChunks/CarrotHead.tscn")
onready var _CarrotTip = load("res://ChoppingStation/Carrot/carrotChunks/CarrotTip.tscn")

# Initialized in _ready
var _state
var entered = false

func _ready():
	_enter_state(GameState.DRAGGING)
	
	var _Carrot = get_tree().get_root().find_node("Carrot",true,false)
	_Carrot.connect("_CarrotHeadChopped", self, "_CarrotHeadChopped")
	_Carrot.connect("_CarrotTipChopped", self, "_CarrotTipChopped")
	
func _physics_process(_delta):
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
			$Carrot.position = $Basket.position

		GameState.CHOPPING:
			# Here we would move the knife into position
			print('Entering the CHOPPING state')
			$Carrot.position = $CuttingBoard.position
			$Carrot._startChopping()


func _on_CuttingBoard_body_entered(_body):
	entered = true


func _on_CuttingBoard_body_exited(_body):
	 entered = false

func _CarrotHeadChopped():
	#Spawns in Carrot Head Scene
	var _carrotHeadInstance = _carrotHead.instance()
	_carrotHeadInstance.set_position(Vector2(470,550))
	add_child(_carrotHeadInstance)
	_carrotHeadInstance._enableDragging()

func	_CarrotTipChopped():
	#Spawns in Carrot Tip Scene
	var _carrotTipInstance = _CarrotTip.instance()
	_carrotTipInstance.set_position(Vector2(775,535))
	add_child(_carrotTipInstance)
	_carrotTipInstance._enableDragging()
