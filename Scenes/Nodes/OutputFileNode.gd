extends "res://Scenes/Nodes/base_node.gd"

var file_path = ""
var write_data = null
var write_data_type = null

func is_export_node():
	return true

func get_exported_output_slots():
	var slots = []
	var slot = {}
	slot["name"] = "Filepath"
	slot["type"] = SlotType.STRING
	slots.append(slot)
	return slots

func _get_file_path():
	if len(file_path) > 0:
		return file_path
	return $HBoxContainer2/FilePath.text

func save():
	var s = {}
	s["file_path"] = make_string_value($HBoxContainer2/FilePath.text)
	s["append"] = $Append.pressed
	return s

func load(json):
	if json.has("file_path"):
		$HBoxContainer2/FilePath.text = json["file_path"]["value"]
	elif json.has("append"):
		$Append.pressed = json["append"]

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		file_path = data["value"]
	elif slot == 1:
		write_data = data["value"]
		write_data_type = data["type"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		return make_string_value(_get_file_path())

func node_connected(slot):
	if slot == 0:
		$HBoxContainer2/FilePath.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer2/FilePath.editable = true
		file_path = ""
	elif slot == 1:
		write_data = null
	pending_inputs -= 1

# Special function for just output nodes
func process_output():
	if write_data and write_data_type:
		var target_file = File.new()
		if $Append.pressed:
			target_file.open(_get_file_path(), File.READ_WRITE)
			target_file.seek_end()
		else:
			target_file.open(_get_file_path(), File.WRITE)
		if write_data_type == 2:
			target_file.store_buffer(write_data)
		elif write_data_type == 3:
			target_file.store_string(write_data.join("\n"))
		else:
			target_file.store_string(write_data)
		target_file.close()
		print(_get_file_path(), " written")
	else:
		_error("Null data sent to OutputFileNode")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
