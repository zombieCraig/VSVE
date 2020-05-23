extends "res://Scenes/Nodes/base_node.gd"

var base_str = null
var split_by = null

func output_offset_hax(slot_id):
	return slot_id + 2

func save():
	var s = {}
	s["split_by"] = $HBoxContainer/SplitBy.text
	return s

func load(json):
	if json.has("split_by"):
		$HBoxContainer/SplitBy.text = json["split_by"]

func node_connected(slot):
	if slot == 1:
		$HBoxContainer/SplitBy.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 1:
		$HBoxContainer/SplitBy.editable = true
		split_by = null
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		base_str = data["value"]
	if slot == 1:
		split_by = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		if base_str:
			var sb = _get_split_by()
			if sb:
				return make_string_array_value(base_str.split(sb))
			else:
				return make_string_array_value(PoolStringArray(base_str))
		else:
			_error("Must supply an incoming string")

func _get_split_by():
	if split_by:
		return split_by
	if len($HBoxContainer/SplitBy.text) > 0:
		return $HBoxContainer/SplitBy.text
	return " "

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
