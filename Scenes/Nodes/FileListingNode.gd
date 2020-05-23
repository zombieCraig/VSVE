extends "res://Scenes/Nodes/base_node.gd"

var starting_dir = null
var file_types = null

func output_offset_hax(slot_id):
	return slot_id + 4

func save():
	var s = {}
	s["starting_dir"] = make_string_value($Dir/StartingDir.text)
	s["file_types"] = make_string_value($FT/FileTypes.text)
	s["recursive"] = $Recursive.pressed
	s["hidden"] = $Hidden.pressed
	return s

func load(json):
	if json.has("starting_dir"):
		$Dir/StartingDir.text = json["starting_dir"]["value"]
	elif json.has("file_types"):
		$FT/FileTypes.text = json["file_types"]["value"]
	elif json.has("recursive"):
		$Recursive.pressed = json["recursive"]
	elif json.has("hidden"):
		$Hidden.pressed = json["hidden"]

func node_connected(slot):
	if slot == 0:
		$Dir/StartingDir.editable = false
	elif slot == 1:
		$FT/FileTypes.editable = false
	pending_inputs += 1

func node_disconnected(slot):
	if slot == 0:
		$Dir/StartingDir.editable = true
		starting_dir = null
	elif slot == 1:
		$FT/FileTypes.editable = true
		file_types = null
	pending_inputs -= 1

func set_input(slot, data):
	if !data.has("value"):
		print("ERROR set_input on FileListingNode but data has no value")
		return
	if slot == 0:
		starting_dir = data["value"]
	elif slot == 1:
		file_types = data["value"]
	pending_inputs -= 1

func get_output(slot):
	if slot == 0:
		var filepaths = PoolStringArray()
		var dir = starting_dir
		if !dir:
			dir = $Dir/StartingDir.text
		var types = file_types
		if !file_types:
			types = $FT/FileTypes.text
		if dir and types:
			var do_recursive = $Recursive.pressed
			var dir_q = [dir]
			var current_dir: Directory
			var current_file: String
			while current_file or not dir_q.empty():
				if current_file:
					if current_dir.current_is_dir():
						if do_recursive:
							dir_q.append("%s/%s" % [current_dir.get_current_dir(), current_file])
					else:
						var tmatch = false
						if types == "*":
							tmatch = true
						else:
							var regex = RegEx.new()
							var err = regex.compile(types)
							if err == OK:
								var found = regex.search(current_file)
								if found:
									filepaths.append("%s/%s.%s" % [current_dir.get_current_dir(), current_file.get_basename(), current_file.get_extension()])
							else:
								_error("Couldn't parse file types as regex")
						if tmatch:
							filepaths.append("%s/%s.%s" % [current_dir.get_current_dir(), current_file.get_basename(), current_file.get_extension()])
				else:
					# No more files
					if current_dir:
						current_dir.list_dir_end()
					if dir_q.empty():
						break
					current_dir = Directory.new()
					current_dir.open(dir_q.pop_front())
					current_dir.list_dir_begin(true, $Hidden.pressed)
				current_file = current_dir.get_next()
		else:
			_error("Requires both a starting dir and a file type")
		return make_string_array_value(filepaths)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

