class_name Plug extends Sprite2D

enum SignalType {VIDEO_IN, VIDEO_OUT, POWER_IN, POWER_OUT}
enum VideoOut {OCULAR, SONAR, INFORMATION, PROXIMITY, STATUS}
enum DrawTarget {NONE, MOUSE, PLUG}

@export var signal_type: SignalType = SignalType.POWER_OUT
@export var video_output: VideoOut = VideoOut.SONAR
@export var label_text: String = ""

var connections: Array = []
var incoming_power_level: int = 0
var incoming_video_signals: Array = []
var drawing: bool = false
var drawing_target: DrawTarget = DrawTarget.NONE
var draw_plug: Plug = null

signal CONNECTION_ATTEMPT(other: Plug)
signal CONNECTION_OFFER(other: Plug)
signal CONNECTION_DELETE(other: Plug)

func _process(delta: float) -> void:
	
	if drawing:
		if drawing_target == DrawTarget.MOUSE:
			draw_line(global_position, get_global_mouse_position(), Color.WHITE)
		if drawing_target == DrawTarget.PLUG:
			draw_line(global_position, draw_plug.global_position, Color.WHITE)
	
	# outputters do nothing 
	if signal_type == SignalType.VIDEO_OUT or signal_type == SignalType.POWER_OUT:
		return
	# power in just needs at least 1 power
	if signal_type == SignalType.POWER_IN:
		if incoming_power_level > 0:
			# do something
			pass
	# video in must be unique
	if signal_type == SignalType.VIDEO_IN:
		if incoming_video_signals.size() == 0:
			# display nothing
			pass
		if incoming_video_signals.size() == 1:
			# display panel
			pass
		if incoming_video_signals.size() > 1:
			# display error 
			pass 

# when the receiver plug is notified that the mouse has been released on it
func _on_connection_attempt(other: Plug) -> void:
	connections.append(other)
	emit_signal("CONNECTION_OFFER", self) # tell the origin plug the id of this plug

# when the origin plug is notified which plug its wire has been released on
func _on_connection_offer(other: Plug) -> void:
	connections.append(other)
	draw_plug = other
	
func _on_connection_delete(other: Plug) -> void:
	connections.erase(other)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			print("CLICK")
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			SignalBus.emit_signal("PLUG_PICKED", self)
			drawing = true
		if event.is_released():
			print("UNCLICK")
			# cursor change is handled by Game so dropped wires don't make the icon stuck
			SignalBus.emit_signal("PLUG_DROPPED")
			self.emit_signal("CONNECTION_ATTEMPT", Hand.held_plug)
			
