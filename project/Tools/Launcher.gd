extends Control

var _pids := []

onready var _spinbox := find_node("SpinBox")
onready var _kill_button := find_node("KillButton")


func _on_LaunchButton_pressed():
	$ButtonClick.play()
	var number := _spinbox.value as int
	assert(number > 0)
	for i in number:
		var pid = OS.execute(OS.get_executable_path(), [], false)
		_pids.append(pid)
	_kill_button.disabled = false


func _on_KillButton_pressed():
	$ButtonClick.play()
	while not _pids.empty():
		var pid : int = _pids.pop_front()
		var error := OS.kill(pid)
		if error:
			print("Error encountered killing process %d: %s" % [pid, str(error)])
	_kill_button.disabled = true
