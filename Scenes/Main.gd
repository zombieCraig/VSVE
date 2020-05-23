extends Control

onready var NodeSearch = $VBoxContainer/HBoxContainer/HSplitContainer/SearchContainer/NodeSearch
onready var NodeTree = $VBoxContainer/HBoxContainer/HSplitContainer/SearchContainer/NodeTree
onready var Graph = $VBoxContainer/HBoxContainer/HSplitContainer/GraphContainer/GraphEdit
onready var GraphContainer = $VBoxContainer/HBoxContainer/HSplitContainer/GraphContainer

var root = null

var nodes_created = 0
var over_tree = false
var drop_node = null

enum SlotType {
	UNDEF = 0,
	STRING,
	BINARY,
	STRING_ARRAY
}

export(Color) var UndefNodeColor
export(Color) var StringNodeColor
export(Color) var BinaryNodeColor
export(Color) var StringArrayNodeColor

var node_styles = {
	"Data": { "bg": "131280"},
	"Ops": { "bg": "#806912" },
	"Input": { "bg": "#804212"},
	"Output": { "bg": "#065f14"},
	"FileSystem": { "bg": "#06445f"},
	"Misc": { "bg": "#393939"}
}

var node_lookup = { 
	"StringVar" : {"scene": "res://Scenes/Nodes/StringVarNode.tscn", "cat": "Data"},
	"BinaryXor" : {"scene": "res://Scenes/Nodes/BinaryXorNode.tscn", "cat": "Ops"},
	"ReplaceString" : {"scene": "res://Scenes/Nodes/ReplaceStringNode.tscn", "cat": "Ops"},
	"String2Array" : {"scene": "res://Scenes/Nodes/String2ArrayNode.tscn", "cat": "Ops"},
	"Array2String" : {"scene": "res://Scenes/Nodes/Array2StringNode.tscn", "cat": "Ops"},
	"PruneArray" : { "scene": "res://Scenes/Nodes/PruneArrayNode.tscn", "cat": "Ops"},
	"OutputFile": {"scene": "res://Scenes/Nodes/OutputFileNode.tscn", "cat": "Output"},
	"InputFile" : {"scene": "res://Scenes/Nodes/InputFileNode.tscn", "cat": "Input"},
	"InputTextFile" : {"scene": "res://Scenes/Nodes/InputTextFileNode.tscn", "cat": "Input"},
	"PickRandomElement": {"scene": "res://Scenes/Nodes/PickRandomElementNode.tscn", "cat": "Ops" },
	"FileListing": {"scene": "res://Scenes/Nodes/FileListingNode.tscn", "cat": "FileSystem"},
	"DeleteFile": {"scene": "res://Scenes/Nodes/DeleteFileNode.tscn", "cat": "FileSystem"},
	"CmdExecute" : { "scene": "res://Scenes/Nodes/CmdExecuteNode.tscn", "cat": "FileSystem"},
	"Legend"    : {"scene": "res://Scenes/Nodes/LegendNode.tscn", "cat": "Misc"},
	 }

# Validates node colors and sets up connection hooks
func _setup_new_node(new_node):
	new_node.connect("close_request", self, "_on_node_close", [new_node])
	new_node.connect("node_error", self, "_on_node_error", [new_node])
	if new_node.resizable:
		new_node.connect("resize_request", self, "_on_node_resize", [new_node])
	if new_node.has_method("register_connects"):
		var signals = new_node.register_connects()
		for s in signals:
			if s["type"] == "OpenFileDialog":
				s["obj"].connect(s["signal"], self, "_on_node_openfiledialog", [new_node, s["method"]])
	# Redo slot colors to ensure they are the same
	var slots = {}
	for idx in range(0, new_node.get_connection_input_count()):
		var slot_id = idx
		if new_node.has_method("input_offset_hax"):
			slot_id = new_node.input_offset_hax(idx)
		if new_node.is_slot_enabled_left(slot_id):
			var slot_type = new_node.get_connection_input_type(idx)
			slots[slot_id] = {}
			slots[slot_id]["left"] = slot_type
			match slot_type:
				SlotType.UNDEF:
					slots[slot_id]["lcolor"] = UndefNodeColor
				SlotType.STRING:
					slots[slot_id]["lcolor"] = StringNodeColor
				SlotType.BINARY:
					slots[slot_id]["lcolor"] = BinaryNodeColor
				SlotType.STRING_ARRAY:
					slots[slot_id]["lcolor"] = StringArrayNodeColor
				_:
					print("ERROR: Unknown input node type (add_node)")
	for idx in range(0, new_node.get_connection_output_count()):
		# Godot currently is missing a proper way to cycle through slots
		var slot_id = idx
		if new_node.has_method("output_offset_hax"):
			slot_id = new_node.output_offset_hax(idx)
		if new_node.is_slot_enabled_right(slot_id):
			var slot_type = new_node.get_connection_output_type(idx)
			if !slots.has(slot_id):
				slots[slot_id] = {}
			slots[slot_id]["right"] = slot_type
			match slot_type:
				SlotType.UNDEF:
					slots[slot_id]["rcolor"] = UndefNodeColor
				SlotType.STRING:
					slots[slot_id]["rcolor"] = StringNodeColor
				SlotType.BINARY:
					slots[slot_id]["rcolor"] = BinaryNodeColor
				SlotType.STRING_ARRAY:
					slots[slot_id]["rcolor"] = StringArrayNodeColor
				_:
					print("ERROR: Unknown output node type (add_node)")
	for slot_id in slots:
		var ltype = 0
		var lcolor = Color()
		var rtype = 0
		var rcolor = Color()
		if slots[slot_id].has("left"):
			ltype = slots[slot_id]["left"]
			lcolor = slots[slot_id]["lcolor"]
		if slots[slot_id].has("right"):
			rtype = slots[slot_id]["right"]
			rcolor = slots[slot_id]["rcolor"]
		new_node.set_slot(slot_id, slots[slot_id].has("left"), ltype, lcolor, slots[slot_id].has("right"), rtype, rcolor)

func style_node(node, node_config):
	if node_styles.has(node_config["cat"]):
		var style = node_styles[node_config["cat"]]
		if style.has("bg"):
			var sb = StyleBoxFlat.new()
			sb.bg_color = Color(style["bg"])
			node.set('custom_styles/frame', sb)

func add_node(direct=false, offset = Vector2(10, 10)):
	var item = NodeTree.get_selected()
	if item:
		var item_name = item.get_text(0)
		if item_name and node_lookup.has(item_name):
			var new_node = load(node_lookup[item_name]["scene"]).instance()
			if direct:
				new_node.offset = offset
			else:
				new_node.offset += Vector2(20 + (nodes_created * offset.x),40 + (nodes_created * offset.y))
			new_node.show_close = true
			Graph.add_child(new_node)
			_setup_new_node(new_node)
			#style_node(new_node, node_lookup[item_name])
			nodes_created += 1

func get_node_by_name(n):
	for node in Graph.get_children():
		if node.name == n:
			return node

func save_graph(file_path):
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(_graph_to_json())
	file.close()

func load_graph(file_path):
	GraphContainer.remove_child(Graph)
	#Graph = load("res://saves/graph.tscn").instance()
	var file = File.new()
	file.open(file_path, File.READ)
	var text = file.get_as_text()
	file.close()
	var res = JSON.parse(text)
	if res.error == OK:
		_json_to_graph(res.result)
	else:
		GraphContainer.add_child(Graph)

func show_alert(msg, title):
	$AlertDialog.window_title = title
	$AlertDialog.dialog_text = msg
	$AlertDialog.popup_centered()

func clear_node_overlays():
	for node in Graph.get_children():
		if node.get_class() == "GraphNode":
			node.overlay = GraphNode.OVERLAY_DISABLED

func _add_cat_item(cat_name, node_name):
	var cat = root.get_children()
	while cat:
		if cat.get_text(0) == cat_name:
			NodeTree.create_item(cat).set_text(0, node_name)
			return
		cat = cat.get_next()

func _populate_child_nodes():
	var unique_cat = {}
	for n in node_lookup:
		unique_cat[node_lookup[n]["cat"]] = true
	for cat in unique_cat:
		var cat_item = NodeTree.create_item(root)
		cat_item.set_text(0, cat)
		if node_styles.has(cat):
			var style = node_styles[cat]
			if style.has("bg"):
				cat_item.set_custom_bg_color(0, Color(style["bg"]))
	for n in node_lookup:
		_add_cat_item(node_lookup[n]["cat"], n)

func _init_graphedit():
	Graph.connect("connection_request", self, "_on_GraphEdit_connection_request")
	Graph.connect("disconnection_request", self, "_on_GraphEdit_disconnection_request")
	Graph.add_valid_connection_type(SlotType.UNDEF, SlotType.STRING)
	Graph.add_valid_connection_type(SlotType.UNDEF, SlotType.BINARY)
	Graph.add_valid_connection_type(SlotType.UNDEF, SlotType.STRING_ARRAY)
	# Style it
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#01040d")
	Graph.set("custom_styles/bg", sb)
	Graph.set("custom_colors/grid_major", Color("#560202"))
	Graph.set("custom_colors/grid_minor", Color("#1c0202"))

# Called when the node enters the scene tree for the first time.
func _ready():
	root = NodeTree.create_item()
	NodeTree.set_hide_root(true)
	_populate_child_nodes()
	_init_graphedit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _graph_to_json():
	var save = {}
	save["connections"] = Graph.get_connection_list()
	save["right_disconnects"] = Graph.right_disconnects
	save["nodes"] = {}
	for node in Graph.get_children():
		if node.get_class() == "GraphNode":
			save["nodes"][node.name] = {}
			save["nodes"][node.name]["show_close"] = node.show_close
			save["nodes"][node.name]["resizable"] = node.resizable
			save["nodes"][node.name]["comment"] = node.comment
			save['nodes'][node.name]["scene"] = node.get_filename()
			save["nodes"][node.name]["offset"] = node.offset
			if node.has_method("save"):
				save["nodes"][node.name]["save"] = node.save()
	return JSON.print(save)

func _json_to_graph(json_save):
	if !json_save.has("right_disconnects"):
		push_error("Invalid json save file")
		return
	var new_graph = GraphEdit.new()
	new_graph.name = "GraphEdit"
	GraphContainer.add_child(new_graph)
	new_graph.right_disconnects = json_save["right_disconnects"]
	new_graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for node_name in json_save["nodes"]:
		var save_node = json_save["nodes"][node_name]
		var new_node = load(save_node["scene"]).instance()
		new_node.show_close = save_node["show_close"]
		new_node.resizable = save_node["resizable"]
		new_node.comment = save_node["comment"]
		new_node.offset = str2var("Vector2"+save_node["offset"])
		if save_node.has("save") and new_node.has_method("load"):
			new_node.load(save_node["save"])
		new_node.name = node_name
		_setup_new_node(new_node)
		new_graph.add_child(new_node)
	# Now that nodes are loaded, reconnect them
	Graph = new_graph
	_init_graphedit()
	for connection in json_save["connections"]:
		_on_GraphEdit_connection_request(connection["from"].replace("@",""), connection["from_port"], connection["to"].replace("@",""), connection["to_port"])

func _input(event):
	if event.is_action_pressed("tree_accept"):
		# Some Checks
		if $MakeNodeDialog.visible or $FileDialog.visible or $AlertDialog.visible:
			return
		add_node()
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if over_tree:
				drop_node = NodeTree.get_selected()
			else:
				drop_node = null
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			if drop_node:
				var graph_loc = Graph.rect_global_position
				var graph_sz = Graph.rect_size
				var mouse_loc = event.get_position()
				if mouse_loc.x >= graph_loc.x and mouse_loc.x <= graph_sz.x and mouse_loc.y >= graph_loc.y and mouse_loc.y <= graph_sz.y:
					add_node(true, Vector2(mouse_loc.x - graph_loc.x, mouse_loc.y - graph_loc.y))
				elif drop_node:
					drop_node = null

func _on_NodeTree_item_activated():
	add_node()

func _on_node_resize(new_size, node):
	node.rect_size = new_size

func _on_node_close(node):
	#Disconnect node first
	for connection in Graph.get_connection_list():
		if connection["from"] == node.name or connection["to"] == node.name:
			_on_GraphEdit_disconnection_request(connection["from"], connection["from_port"], connection["to"], connection["to_port"])
	node.queue_free()

func _on_node_error(msg, node):
	# If we already have an alert don't overwrite
	if $AlertDialog.visible == false:
		show_alert(msg, node.name + " ERROR")
	node.overlay = GraphNode.OVERLAY_POSITION

func _on_NodeSearch_text_changed(new_text):
	if len(new_text) == 0:
		return
	new_text = new_text.to_lower()
	var child = root.get_children()
	while child != null:
		var nodes = child.get_children()
		while nodes != null:
			var t = nodes.get_text(0)
			if t.to_lower().begins_with(new_text):
				nodes.select(0)
			nodes = nodes.get_next()
		child = child.get_next()

func _process_output_queue(q):
	if q.size() > 0:
		for connection in q:
			var from = Graph.get_node(connection["from"])
			if !from.is_pending():
				var value = from.get_output(connection["from_port"])
				var to = Graph.get_node(connection["to"])
				if to:
					if value and to.has_method("set_input"):
						to.set_input(connection["to_port"], value)
				q.erase(connection)

func _on_RunBtn_pressed():
	clear_node_overlays()
	var output_q = []
	var list = Graph.get_connection_list()
	for connection in list:
		var value = null
		var from = Graph.get_node(connection["from"])
		if from and from.has_method("get_output"):
			if from.is_pending():
				output_q.append(connection)
			else:
				value = from.get_output(connection["from_port"])
				var to = Graph.get_node(connection["to"])
				if to:
					if value and to.has_method("set_input"):
						to.set_input(connection["to_port"], value)
		_process_output_queue(output_q)
	if output_q.size() > 0:
		for conn in output_q:
			_on_node_error("Output Q still pending", Graph.get_node(conn["from"]))
	# We only run 'process_output' once everything is connected
	var output_node = {}
	for connection in list:
		var to = Graph.get_node(connection["to"])
		if to.has_method("process_output"):
			output_node[to] = true
	# Ensure it only runs once
	for to in output_node:
		to.process_output()

func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	var target = get_node_by_name(to)
	if target and target.has_method("node_connected"):
		target.node_connected(to_slot)
	Graph.connect_node(from, from_slot, to, to_slot)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	var target = get_node_by_name(to)
	if target.has_method("node_disconnected"):
		target.node_disconnected(to_slot)
	Graph.disconnect_node(from, from_slot, to, to_slot)

func _on_SaveBtn_pressed():
	$FileDialog.mode = FileDialog.MODE_SAVE_FILE
	$FileDialog.current_dir = "res://saves/"
	$FileDialog.current_path = "res://saves/"
	$FileDialog.popup()

func _on_LoadBtn_pressed():
	$FileDialog.mode = FileDialog.MODE_OPEN_FILE
	$FileDialog.current_dir = "res://saves/"
	$FileDialog.current_path = "res://saves/"
	$FileDialog.popup()

func _on_ClearBtn_pressed():
	Graph.clear_connections()
	for node in Graph.get_children():
		if node.get_class() == "GraphNode":
			_on_node_close(node)

func _on_FileDialog_file_selected(path):
	if $FileDialog.mode == FileDialog.MODE_SAVE_FILE:
		save_graph(path)
	elif $FileDialog.mode == FileDialog.MODE_OPEN_FILE:
		load_graph(path)
	$FileDialog.hide()

func _on_node_openfiledialog(node, method):
	var fd = FileDialog.new()
	add_child(fd)
	fd.mode = FileDialog.MODE_OPEN_FILE
	fd.popup_centered_ratio(0.5)
	fd.connect("file_selected", self, "_on_node_openfiledialog_selected", [fd, node, method])

func _on_node_openfiledialog_selected(path, fd, node, method):
	if node.has_method(method):
		node.call(method, path)
	remove_child(fd)

func _on_MakeNodeBtn_pressed():
	var list = Graph.get_connection_list()
	var input_slots = {}
	var output_slots = {}
	if len(list) > 0:
		for connection in list:
			var from = Graph.get_node(connection["from"])
			if from.is_input_node():
				var slots = from.get_exported_input_slots()
				for slot in slots:
					var le = LineEdit.new()
					le.text = slot["name"]
					$MakeNodeDialog/Rows/Slots/Inputs.add_child(le)
					input_slots[connection["from"]] = slot
			var to = Graph.get_node(connection["to"])
			if to.is_export_node():
				pass
		if input_slots.size() == 0 and output_slots.size() == 0:
			show_alert("You need to have at least 1 Input/Export connected node", "ERROR")
		else:
			$MakeNodeDialog.popup_centered()
	else:
		show_alert("You need at least 1 connected node", "ERROR")

func _on_MakeNodeDialog_confirmed():
	pass

func _on_NodeTree_mouse_entered():
	over_tree = true

func _on_NodeTree_mouse_exited():
	over_tree = false

