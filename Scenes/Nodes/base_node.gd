extends GraphNode

signal node_error(msg)

var pending_inputs = 0

enum SlotType {
	UNDEF = 0,
	STRING,
	BINARY,
	STRING_ARRAY,
}

func is_input_node():
	return false

func is_export_node():
	return false

func get_exported_input_slots():
	return []

func get_exported_output_slots():
	return []

func make_undef_value(d):
	var v = {}
	v["value"] = d
	v["type"] = SlotType.UNDEF
	return v

func make_string_value(s):
	var v = {}
	v["value"] = s
	v["type"] = SlotType.STRING
	return v

func make_binary_value(b):
	var v = {}
	v["value"] = b
	v["type"] = SlotType.BINARY
	return v

func make_string_array_value(b):
	var v = {}
	v["value"] = b
	v["type"] = SlotType.STRING_ARRAY
	return v

func node_connected(_slot):
	pending_inputs += 1

func node_disconnected(_slot):
	pending_inputs -= 1

func is_pending():
	return pending_inputs > 0

func set_input(_slot, _data):
	pending_inputs -= 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _error(msg):
	emit_signal("node_error", msg)
