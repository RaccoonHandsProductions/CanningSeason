extends Control

onready var _carrot_label := get_node("CarrotCount")
onready var _sanatized_jars_label := get_node("SanatizedJarsCount")
onready var _canned_label := get_node("CannedCount")
onready var _total_label := get_node("TotalScore")

var _carrot_count := 0
var _clean_jar_count := 0
var _full_jar_count := 0

func _ready():
	#set scores from other tablets here
	_carrot_count = 0
	_clean_jar_count = 0
	_full_jar_count = 0
	
	_set_labels(_carrot_count, _clean_jar_count, _full_jar_count)

#leftover carrots = 5pts, leftover jars = 5pts, full jars = 20pts
func _set_labels(var carrots, var cleanJars, var fullJars):
	_carrot_label.text = str(carrots)
	_sanatized_jars_label.text = str(cleanJars)
	_canned_label.text = str(fullJars)
	
	_total_label.text = str((carrots + cleanJars + fullJars * 4) * 5)
