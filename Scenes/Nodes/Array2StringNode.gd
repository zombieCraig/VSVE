extends "res://Scenes/Nodes/base_node.gd"

var base_array = null
var join_with = null

func output_offset_hax(slot_id):
	return slot_id + 2

func save():
	var s = {}
	s["join_with"] = $HBoxContainer/JoinWith.text
	return s

func load(json):
	if json.has("join_with"):
		$HBoxContainer/JoinWith.text = json["join_with"]

func node_connected(slot):
	if slot == 1:
		$HBoxContainer/JoinWith.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 1:
		$HBoxContainer/JoinWith.editable = true
		join_with = null
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		base_array = data["value"]
	if slot == 1:
		join_with = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		if base_array:
			return make_string_value(base_array.join(_get_join_by()))
		else:
			_error("You must specify a string array")

func _get_join_by():
	if join_with:
		return join_with
	if len($HBoxContainer/JoinWith.text) > 0:
		return $HBoxContainer/JoinWith.text
	return ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
