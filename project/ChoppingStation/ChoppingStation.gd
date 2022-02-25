extends Node2D


#Defines the different Game States
enum GameState{
	DRAGGING,
	CHOPPING,
	SORTING
}

#Loads each chunk to be spawned in
onready var _carrot_head := load("res://ChoppingStation/Carrot/carrotChunks/CarrotHead.tscn")
onready var _carrot_tip := load("res://ChoppingStation/Carrot/carrotChunks/CarrotTip.tscn")
onready var _carrot_chunk_left := load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkLeft.tscn")
onready var _carrot_chunk_middle := load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkMiddle.tscn")
onready var _carrot_chunk_right := load("res://ChoppingStation/Carrot/carrotChunks/CarrotChunkRight.tscn")

# Initialized in _ready
var _state
var _has_entered := false


func _ready():
	_enter_state(GameState.DRAGGING)
	
	#Connects signals from Carrot.tscn
	var _carrot := get_tree().get_root().find_node("Carrot",true,false)
	_carrot.connect("carrot_head_chopped", self, "_on_carrot_head_chopped")
	_carrot.connect("carrot_4_5_chopped", self, "_on_carrot_4_5_chopped")
	_carrot.connect("carrot_3_5_chopped", self, "_on_carrot_3_5_chopped")
	_carrot.connect("carrot_2_5_chopped", self, "_on_carrot_2_5_chopped")


func _physics_process(_delta):
	#changes state to Chopping if carrot is released on the cutting board
	if _has_entered == true && $Carrot._dragging == false && _state == GameState.DRAGGING:
		_enter_state(GameState.CHOPPING)


func _enter_state(new_state)->void:
	# Handle the logic for leaving the old state
	match _state:
		GameState.DRAGGING:
			print('Leaving the dragging state')
			$Carrot._disable_dragging()
	
	# Assign the state to the new state
	_state = new_state
	
	# Handle the logic for entering the new state
	match new_state:
		GameState.DRAGGING:
			# Activate the top carrot (or spawn one in for now, or something)
			print('Entering the DRAGGING state')
			$Carrot._enable_dragging()
			$Carrot.position = $Basket.position

		GameState.CHOPPING:
			# Here we would move the knife into position
			print('Entering the CHOPPING state')
			$Carrot.position = $CuttingBoard.position
			$Carrot._start_chopping()


func _on_CuttingBoard_body_entered(_body)-> void:
	_has_entered = true


func _on_CuttingBoard_body_exited(_body)-> void:
	 _has_entered = false


func _on_carrot_head_chopped()-> void:
	#Spawns in Carrot Head Scene
	var _carrot_head_instance = _carrot_head.instance()
	_carrot_head_instance.set_position(Vector2(450,540))
	$Carrot.position.x += 5
	add_child(_carrot_head_instance)
	_carrot_head_instance._enableDragging()


func _on_carrot_4_5_chopped()-> void:
	#Spawns in Carrot Tip Scene
	var _carrot_chunk_left_instance = _carrot_chunk_left.instance()
	_carrot_chunk_left_instance.set_position(Vector2(550,550))
	$Carrot.position.x += 5
	add_child(_carrot_chunk_left_instance)
	_carrot_chunk_left_instance._enableDragging()


func _on_carrot_3_5_chopped()-> void:
	#Spawns in Carrot Tip Scene
	var _carrot_chunk_middle_instance = _carrot_chunk_middle.instance()
	_carrot_chunk_middle_instance.set_position(Vector2(655,555))
	$Carrot.position.x += 5
	add_child(_carrot_chunk_middle_instance)
	_carrot_chunk_middle_instance._enableDragging()


func _on_carrot_2_5_chopped()-> void:
	#Spawns in Carrot Tip Scene
	var _carrot_chunk_right_instance = _carrot_chunk_right.instance()
	var _carrot_tip_instance = _carrot_tip.instance()
	_carrot_chunk_right_instance.set_position(Vector2(750,560))
	_carrot_tip_instance.set_position(Vector2(845, 560))
	add_child(_carrot_chunk_right_instance)
	add_child(_carrot_tip_instance)
	_carrot_chunk_right_instance._enableDragging()
	_carrot_tip_instance._enableDragging()
