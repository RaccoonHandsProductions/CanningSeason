extends Node2D

enum GameState{
	DRAGGING,
	CHOPPING,
	SORTING
}

onready var _carrotHead = load("res://ChoppingStation/Carrot/carrotChunks/CarrotHead.tscn")
onready var _CarrotTip = load("res://ChoppingStation/Carrot/carrotChunks/CarrotTip.tscn")
onready var _CarrotChunkLeft = load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkLeft.tscn")
onready var _CarrotChunkMiddle = load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkMiddle.tscn")
onready var _CarrotChunkRight = load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkRight.tscn")

# Initialized in _ready
var _state
var entered = false

func _ready():
	_enter_state(GameState.DRAGGING)
	
	var _Carrot = get_tree().get_root().find_node("Carrot",true,false)
	_Carrot.connect("_CarrotHeadChopped", self, "_CarrotHeadChopped")
	_Carrot.connect("_Carrot4_5Chopped", self, "_Carrot4_5Chopped")
	_Carrot.connect("_Carrot3_5Chopped", self, "_Carrot3_5Chopped")
	_Carrot.connect("_Carrot2_5Chopped", self, "_Carrot2_5Chopped")
	
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
	_carrotHeadInstance.set_position(Vector2(450,540))
	$Carrot.position.x += 5
	add_child(_carrotHeadInstance)
	_carrotHeadInstance._enableDragging()

func _Carrot4_5Chopped():
	#Spawns in Carrot Tip Scene
	var _carrotChunkLeft_Instance = _CarrotChunkLeft.instance()
	_carrotChunkLeft_Instance.set_position(Vector2(550,550))
	$Carrot.position.x += 5
	add_child(_carrotChunkLeft_Instance)
	_carrotChunkLeft_Instance._enableDragging()
	
func _Carrot3_5Chopped():
	#Spawns in Carrot Tip Scene
	var _carrotChunkMiddle_Instance = _CarrotChunkMiddle.instance()
	_carrotChunkMiddle_Instance.set_position(Vector2(655,555))
	$Carrot.position.x += 5
	add_child(_carrotChunkMiddle_Instance)
	_carrotChunkMiddle_Instance._enableDragging()

func _Carrot2_5Chopped():
	#Spawns in Carrot Tip Scene
	var _carrotChunkRight_Instance = _CarrotChunkRight.instance()
	var _carrotTip_Instance = _CarrotTip.instance()
	_carrotChunkRight_Instance.set_position(Vector2(750,560))
	_carrotTip_Instance.set_position(Vector2(845, 560))
	add_child(_carrotChunkRight_Instance)
	add_child(_carrotTip_Instance)
	_carrotChunkRight_Instance._enableDragging()
	_carrotTip_Instance._enableDragging()
