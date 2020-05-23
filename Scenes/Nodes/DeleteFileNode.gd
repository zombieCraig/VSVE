extends "res://Scenes/Nodes/base_node.gd"

var filepath = null

func _get_file_path():
	if len(filepath) > 0:
		return filepath
	return $HBoxContainer/FilePath.text

func save():
	var s = {}
	s["filepath"] = make_string_value($HBoxContainer/FilePath.text)
	return s

func load(json):
	if json.has("filepath"):
		$HBoxContainer/FilePath.text = json["filepath"]

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		filepath = data["value"]
	pending_inputs -= 1

func node_connected(slot):
	if slot == 0:
		$HBoxContainer/FilePath.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer/FilePath.editable = true
		filepath = null
	pending_inputs -= 1

# Special function for just output nodes
func process_output():
	var filename = _get_file_path()
	var dir = Directory.new()
	var res = dir.remove(filename)
	if res != OK:
		_error("Couldn't delete file: " + filename)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
