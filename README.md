Visual Scripting Tests
===

This is my sample project to explore using Godot's GraphNodes to create a visual language.  It ended up being more of a generic filesystem like tool.

![VSVE Screenshot](/Screenshot.png)

Project Goals
==
Create a generic interface so that nodes can be easily created and the "core" engine would be able to handle all the main logic.  The goal is to make each node independent and know very little about it's existing environemnt.  Most methods are optional when creating a node and it *should* work with GDNative (other language) based nodes but this is untested at the time of this writing.

TODO
==
* Make Node
There is a button to create your current graph into it's own emedded node.  It will look through the nodes for special nodes that are designed to have inputs and outputs and let you label and categorize your new node.  This is not done yet and there is only some placeholder code in it's place.
* GDNative Nodes
GGNative nodes should work if you follow the method (api) below but this is currently untested.  I would like to create some example nodes that don't use gdscript.

Data Types
==
These are visible in the Legend Node but currently are:
* Any (0)
* String (1)
* Binary Data (2)  (aka BytePool)
* StringArray (3)  (aka StringPool)

Methods / API
==
When creating a Node these are the methods you would use to communicate with the core engine.  All methods are technically optional.

## Save()
Returns a hash for saving.  Only your `load` script will read it so any format you want is fine.  Typically you only want to save things that are editable within your node (LineEdit.text, values, etc)

## Load(json)
This is the hash from your `save()` method above.  This can be

## node_connected(slot)
This is called whenever a node is connected to another node.  Useful for make LineEdits go away or disable.  Note: Slot is the order of your slot but not the slot position (ie: doesn't skip slot counts).  If you use this method make sure you add `pending_inputs += 1` or call the base node.

## node_disconnected(slot)
This is called whenever a node is disconnected.  Useful for restoring states to editable.  If you use this method make sure you add `pending_inputs -= 1` or call the base node.

## set_input(slot, data)
This is called when the application is being run and a node is providing the data for the input slot.

## get_output(slot)
This is called when the application is being run and your node should provide the results of the output of the node for that slot.  This is essentially the `run` section of your node where it does all the things it is meant to do.  This method will not be called until all the connected inputs have been recieved.

## output_offset_hax(slot_id)
This is a hacky way of syncing the slot_id provided by Godot to the actual slot order.  The Engine will color the nodes for you however if you skip a node on output then the coloring will be off.  This is a helper function where you can recalculate the offset.  For instance, say you have 3 slots.  2 are left (input) and the last one is right (output).  The output node is considered the 3rd slot in Godot but it's the only first slot in the array.  In this case the output_offset_hax() should return slot_id + 2.

## input_offset_hax(slot_id)
This is the same as `output_offset_hax` except it is for the input slots.

## is_input_node()
TODO: Used for creating custom nodes

## is_output_node()
TODO: Used for creating custom nodes

## get_exported_input_slots()
TODO: returns an array of hashes (dictionaries).  Each dictionary needs to define its default `name` and `type` (ie. SlotType.String)

## get_exported_output_slots()
TODO: Same as `get_exported_input_slots`.

## register_connects()
Sometimes you have the desire to link additional button and widgets to your node.  This is useful if you want to provide a file browser.  Currently this is only somewaht supported and mainly tested with the file picker right now.  It needs to return an array of hashes (dictionaries) that represent the signals you which to connect to the core engine.  For each dictionary you must specify `obj` => $Object (ie Button), `signal` => signal name (ie: pressed), `type` => OpenFileDialog, `method` => _on_file_selected (Any method in your node you want to call when the signal is triggered)

## Helper Functions
It is recommended you extend `res://Scenes/Nodes/base_node.gd` when creating a node.  It provides several helper functions.

### make_undef_value(data)
Creates a hash for Undef data (`value`) with the meta info (`type`) of SlotType.UNDEF

### make_string_value(data)
Creates a hash for Undef data (`value`) with the meta info (`type`) of SlotType.STRING

### make_binary_value(data)
Creates a hash for Undef data (`value`) with the meta info (`type`) of SlotType.BINARY

### make_string_array_value(data)
Creates a hash for Undef data (`value`) with the meta info (`type`) of SlotType.STRING_ARRAY
