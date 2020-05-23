extends "res://Scenes/Nodes/base_node.gd"

var find = null
var replace_with = null
var data_string = null
var data_string_pool = null

func input_offset_hax(slot_id):
	if slot_id > 0:
		return slot_id + 1
	return slot_id

func output_offset_hax(slot_id):
	return slot_id + 3

func save():
	var s = {}
	s["find"] = make_string_value($HBoxContainer/Find.text)
	s["is_regex"] = $IsRegex.pressed
	s["replace_with"] = make_string_value($HBoxContainer2/With.text)
	return s

func load(json):
	if json.has("find"):
		$HBoxContainer/Find.text = json["find"]["value"]
	if json.has("is_regex"):
		$IsRegex.pressed = json["is_regex"]
	if json.has("replace_with"):
		$HBoxContainer2/With.text = json["replace_with"]["value"]

func node_connected(slot):
	if slot == 0:
		$HBoxContainer/Find.editable = false
	elif slot == 1:
		$HBoxContainer2/With.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer/Find.editable = true
		find = null
	elif slot == 1:
		$HBoxContainer2/With.editable = true
		replace_with = null
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on ReplaceStringNode but data has no value")
		return
	if slot == 0:
		find = data["value"]
	elif slot == 1:
		replace_with = data["value"]
	elif slot == 2:
		data_string = data["value"]
	elif slot == 3:
		data_string_pool = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		var found_data = false
		var result: String
		if data_string:
			found_data = true
			result = replace_str(data_string, _get_find(), _get_with(), $IsRegex.pressed)
		if data_string_pool:
			found_data = true
			for s in data_string_pool:
				result += replace_str(s, _get_find(), _get_with(), $IsRegex.pressed)
		if !found_data:
			_error("Data must be presented as a String and/or String Pool")
			return
		return make_string_value(result)
	elif slot == 1:
		var found_data = false
		var result = PoolStringArray()
		if data_string:
			found_data = true
			result.append(replace_str(data_string, _get_find(), _get_with(), $IsRegex.pressed))
		if data_string_pool:
			found_data = true
			for s in data_string_pool:
				result.append(replace_str(s, _get_find(), _get_with(), $IsRegex.pressed))
		if !found_data:
			_error("Data must be presented as a String and/or String Pool")
			return
		return make_string_array_value(result)

func replace_str(base, search, replace_with_text, is_regex):
	if is_regex:
		var regex = RegEx.new()
		var res = regex.compile(search)
		if res != OK:
			_error("Could not compile regex")
		else:
			return regex.sub(base, replace_with_text, true)
	else:
		return base.replace(search, replace_with_text)

func _get_find():
	if find:
		return find
	elif len($HBoxContainer/Find.text) > 0:
		return $HBoxContainer/Find.text
	else:
		_error("You must specify a find criteria")

func _get_with():
	if replace_with:
		return replace_with
	elif len($HBoxContainer2/With.text):
		return $HBoxContainer2/With.text
	else:
		return ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

