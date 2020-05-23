extends "res://Scenes/Nodes/base_node.gd"

var password = null
var bin_data = null
var password_idx = 0

# Hax
func output_offset_hax(slot_id):
	return slot_id + 1

func save():
	var s = {}
	s["password"] = make_string_value($HBoxContainer/Password.text)
	return s

func load(json):
	if json.has("password"):
		$HBoxContainer/Password.text = json["password"]["value"]

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on binary_xor but data has no value")
		return
	if slot == 0:
		password = data["value"]
	elif slot == 1:
		bin_data = data["value"]
	pending_inputs -= 1

# Password helper function
func get_next_password_byte(bin_password):
	var l = bin_password.size()
	var attempts = 0
	var max_attempts = 10
	var password_byte = null
	while attempts < max_attempts:
		for i in range(password_idx, l):
			if bin_password[i] != 0:
				password_idx += 1
				password_byte = bin_password[i]
				return password_byte
		password_idx = 0
		attempts += 1
	return password_byte

func get_output(slot):
	if slot == 0:
		if !password:
			password = $HBoxContainer/Password.text
		if password and bin_data:
			password_idx = 0
			var bin_password = password.to_utf8()
			var byte_index = 0
			for bin_idx in range(0, bin_data.size()):
				var byte = bin_data[bin_idx]
				if byte != 0:
					var password_byte = get_next_password_byte(bin_password)
					var xor = byte ^ password_byte
					if xor != 0 and byte_index < bin_data.size():
						bin_data.set(byte_index, xor)
				byte_index += 1
		else:
			if !password:
				_error("You must specify a password for this XOR")
			else:
				_error("No input binary data to XOR")
			return null
		return make_binary_value(bin_data)

func node_connected(slot):
	if slot == 0:
		$HBoxContainer/Password.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$HBoxContainer/Password.editable = true
		password = ""
	pending_inputs -= 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
