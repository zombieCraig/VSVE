extends "res://Scenes/Nodes/base_node.gd"

var cmd = null
var args = []

func output_offset_hax(slot_id):
	return slot_id + 2

# For buttons etc
func register_connects():
	var signals = []
	var c = {}
	c["obj"] = $HBoxContainer/SelectBtn
	c["signal"] = "pressed"
	c["type"] = "OpenFileDialog"
	c["method"] = "_on_file_selected"
	signals.append(c)
	return signals

func save():
	var s = {}
	s["cmdpath"] = make_string_value($HBoxContainer/CMD.text)
	s["args"] = make_string_value($HBoxContainer2/Args.text)
	return s

func load(json):
	if json.has("cmdpath"):
		$HBoxContainer/CMD.text = json["cmdpath"]["value"]
	if json.has("args"):
		$HBoxContainer2/Args.text = json["args"]["value"]

func node_connected(slot):
	if slot == 0:
		$HBoxContainer/CMD.editable = false
	elif slot == 1:
		$HBoxContainer2/Args.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer/CMD.editable = true
		cmd = null
	elif slot == 1:
		$HBoxContainer2/Args.editable = true
		args = []
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		cmd = data["value"]
	elif slot == 1:
		args = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		var output = []
		var _error_code = OS.execute(_get_cmd(), _get_args(), true, output, true)
		return make_string_array_value(PoolStringArray(output))

func _get_cmd():
	if cmd:
		return cmd
	if len($HBoxContainer/CMD.text) > 0:
		return $HBoxContainer/CMD.text
	_error("Command not set")

func _get_args():
	if args:
		return args
	if len($HBoxContainer2/Args.text) > 0:
		return $HBoxContainer2/Args.text.split(",")
	return []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_file_selected(bin_cmd):
	$HBoxContainer/CMD.text = bin_cmd
