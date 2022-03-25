extends Panel

const _unfocused_background := Color.blue
const _focused_background := Color.red

var _style := StyleBoxFlat.new()

export var has_focus := false setget _set_has_focus

func _ready():
	add_stylebox_override("panel", _style)
	_update_background()


func _set_has_focus(value:bool)->void:
	has_focus = value
	_update_background()
	
	
func _update_background()->void:
	_style.set_bg_color(_focused_background if has_focus else _unfocused_background)
	update()
