extends Node

var held_plug: Plug = null

func _ready() -> void:
	SignalBus.connect("PLUG_PICKED", _on_plug_picked)
	SignalBus.connect("PLUG_DROPPED", _on_plug_dropped)
	
func _on_plug_picked(origin: Plug) -> void:
	held_plug = origin
	
func _on_plug_dropped() -> void:
	held_plug = null

# man idk why it errors without this...
func get_held_plug() -> Plug:
	return held_plug
