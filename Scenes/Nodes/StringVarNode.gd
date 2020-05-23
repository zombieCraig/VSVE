extends "res://Scenes/Nodes/base_node.gd"


func get_output(slot):
	if slot == 0:
		return make_string_value($String.text)
	return null

func save():
	var save = {}
	save["value"] = $String.text
	return save

func load(json):
	$String.text = json["value"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
