extends "res://Scenes/Nodes/base_node.gd"

var items = null

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on binary_xor but data has no value")
		return
	if slot == 0:
		items = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		if items:
			randomize()
			var chosen = items[randi() % items.size()]
			if !chosen:
				_error("Randomly selected a null value")
				return
			return make_string_value(chosen)
		else:
			_error("No String Array to pick from")
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

