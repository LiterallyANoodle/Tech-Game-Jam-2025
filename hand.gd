extends Node

@export var arrow_cursor: Resource = load("res://hand_ungrab.png")
@export var drag_cursor: Resource = load("res://hand_grab.png")

@onready var wires_parent: Node2D = get_tree().root.get_node_or_null("Level/Character/Interface/Wires")

var held_plug: Plug = null
var held_wire: Wire = null
var hovered_plug: Plug = null
var last_mouse_button: MouseButton = MOUSE_BUTTON_NONE

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(6, 18))
	Input.set_custom_mouse_cursor(drag_cursor, Input.CURSOR_DRAG, Vector2(6, 18))
	
	SignalBus.connect("PLUG_PICKED", _on_plug_picked)
	SignalBus.connect("PLUG_DROPPED", _on_plug_dropped)
	SignalBus.connect("PLUG_HOVERED", _on_plug_hovered)
	SignalBus.connect("PLUG_UNHOVERED", _on_plug_unhovered)
	
func _unhandled_input(event: InputEvent) -> void:
	
	if hovered_plug == null:
		if event is InputEventMouseButton and event.is_released():
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			if held_wire != null:
				held_wire.request_delete()
			SignalBus.emit_signal("PLUG_DROPPED")
		return 
	
	if event is InputEventMouseButton:
		last_mouse_button = event.button_mask
		if event.is_pressed() and last_mouse_button == MOUSE_BUTTON_LEFT:
			print("LEFT CLICK")
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			SignalBus.emit_signal("PLUG_PICKED", hovered_plug)
			var w: Wire = Wire.new()
			w.curve = Curve2D.new()
			w.z_index = 1
			w.curve.add_point(Vector2.ZERO)
			w.curve.add_point(Vector2.ZERO)
			w.held = true
			w.origin = hovered_plug
			hovered_plug.wires.append(w)
			held_wire = w
			wires_parent.add_child(w) # have to be parented elsewhere or the line just doesn't show?
		
		if event.is_pressed() and last_mouse_button == MOUSE_BUTTON_RIGHT:
			print("RIGHT CLICK")
			
			for p: Plug in hovered_plug.connections:
				p.connection_delete(hovered_plug)
				hovered_plug.connection_delete(p) 
			print(hovered_plug.name, " ", hovered_plug.connections)
			
		if event.is_released():
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
			# unclick for plug
			print("UNCLICK")
			# cursor change is handled by Game so dropped wires don't make the icon stuck
			# no self-connections or double-connections allowed
			# only single connections with other plugs, as God intended
			if held_plug != null:
				if held_plug != hovered_plug and held_plug not in hovered_plug.connections:
					hovered_plug.connections.append(held_plug)
					held_plug.connection_acknowledge(hovered_plug)
				else:
					if held_wire != null:
						held_wire.request_delete()
			SignalBus.emit_signal("PLUG_DROPPED") # Do this last
	
func _on_plug_picked(origin: Plug) -> void:
	held_plug = origin
	
func _on_plug_dropped() -> void:
	held_plug = null
	held_wire = null
	
func _on_plug_hovered(hovered: Plug) -> void:
	hovered_plug = hovered
	
func _on_plug_unhovered(unhovered: Plug) -> void:
	if unhovered == hovered_plug:
		hovered_plug = null

# man idk why it errors without this...
func get_held_plug() -> Plug:
	return held_plug
