extends "res://Scenes/Nodes/base_node.gd"

var file_path = null

func is_input_node():
	return true

func get_exported_input_slots():
	var slots = []
	var slot = {}
	slot["name"] = "Filepath"
	slot["type"] = SlotType.STRING
	slots.append(slot)
	return slots

# For buttons etc
func register_connects():
	var signals = []
	var c = {}
	c["obj"] = $HBoxContainer/PickFileBtn
	c["signal"] = "pressed"
	c["type"] = "OpenFileDialog"
	c["method"] = "_on_file_selected"
	signals.append(c)
	return signals

func save():
	var s = {}
	s["file_path"] = make_string_value($HBoxContainer/InputFile.text)
	return s

func load(json):
	if json.has("file_path"):
		$HBoxContainer/InputFile.text = json["file_path"]["value"]

func node_connected(slot):
	if slot == 0:
		$HBoxContainer/InputFile.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer/InputFile.editable = true
		file_path = ""
	pending_inputs += 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		file_path = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		var data = PoolStringArray()
		var target_file = File.new()
		if file_path:
			var res = target_file.open(file_path, File.READ)
			if res != OK:
				_error("Couldn't open file, " + file_path)
				return
		else:
			if len($HBoxContainer/InputFile.text) == 0:
				_error("No Input file specified")
				return null
			var res = target_file.open($HBoxContainer/InputFile.text, File.READ)
			if res != OK:
				_error("Couldn't open file, " + $HBoxContainer/InputFile.text)
				return
		while !target_file.eof_reached():
			var line = target_file.get_line()
			if len(line) > 0:
				data.append(line)
		target_file.close()
		return make_string_array_value(data)
	elif slot == 1:
		var data: String
		var target_file = File.new()
		if file_path:
			var res = target_file.open(file_path, File.READ)
			if res != OK:
				_error("Couldn't open file, " + file_path)
				return
		else:
			if len($HBoxContainer/InputFile.text) == 0:
				_error("No Input file specified")
				return null
			var res = target_file.open($HBoxContainer/InputFile.text, File.READ)
			if res != OK:
				_error("Couldn't open file, " + $HBoxContainer/InputFile.text)
				return
		data = target_file.get_as_text()
		target_file.close()
		return make_string_value(data)
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_file_selected(new_file_path):
	$HBoxContainer/InputFile.text = new_file_path
