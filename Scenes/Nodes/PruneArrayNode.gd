extends "res://Scenes/Nodes/base_node.gd"

var str_array = null
var str_match = null

func save():
	var s = {}
	s["match"] = $HBoxContainer/Match.text
	s["only_matches"] = $HBoxContainer2/OnlyMatches.pressed
	return s

func load(json):
	if json.has("match"):
		$HBoxContainer/Match.text = json["match"]
	if json.has("only_matches"):
		$HBoxContainer2/OnlyMatches.pressed = json["only_matches"]

func node_connected(slot):
	if slot == 1:
		$HBoxContainer/Match.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		str_array = null
	elif slot == 1:
		$HBoxContainer/Match.editable = true
		str_match = null
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on output but data has no value")
		return
	if slot == 0:
		str_array = data["value"]
	if slot == 1:
		str_match = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		var regex = RegEx.new()
		var match_with = _get_match()
		var matches = PoolStringArray()
		if match_with and str_array:
			var err = regex.compile(match_with)
			if err == OK:
				for s in str_array:
					var found = regex.search(s)
					if $HBoxContainer2/OnlyMatches.pressed:
						if found:
							matches.append(s)
					else:
						if !found:
							matches.append(s)
				return make_string_array_value(matches)
			else:
				_error("Match was not a valid regex")
		else:
			_error("You must specify a string array")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _get_match():
	if str_match:
		return str_match
	if len($HBoxContainer/Match.text) > 0:
		return $HBoxContainer/Match.text
	else:
		_error("You must set a match")
