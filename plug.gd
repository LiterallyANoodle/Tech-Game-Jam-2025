class_name Plug extends Sprite2D

enum SignalType {VIDEO_IN, VIDEO_OUT, POWER_IN, POWER_OUT}
enum VideoOut {OCULAR, SONAR, INFORMATION, PROXIMITY, STATUS}

@export var signal_type: SignalType = SignalType.POWER_OUT
@export var video_output: VideoOut = VideoOut.SONAR
@export var label_text: String = ""

var connections: Array = []
var incoming_power_level: int = 0
var incoming_video_signals: Array = []

func _process(delta: float) -> void:
	
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

# when the origin plug is notified which plug its wire has been released on
func connection_acknowledge(other: Plug) -> void:
	if other != self:
		connections.append(other)
		print(self.name, " ", connections)
	
func connection_delete(other: Plug) -> void:
	connections.erase(other)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_LEFT:
			print("LEFT CLICK")
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			SignalBus.emit_signal("PLUG_PICKED", self)
		
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_RIGHT:
			print("RIGHT CLICK")
			for p: Plug in connections:
				emit_signal("CONNECTION_DELETE", p)
				connections.erase(p)
			
		if event.is_released():
			print("UNCLICK")
			# cursor change is handled by Game so dropped wires don't make the icon stuck
			if Hand.held_plug != self:
				connections.append(Hand.held_plug)
				Hand.held_plug.connection_acknowledge(self)
				print(self.name, " ", connections)
			SignalBus.emit_signal("PLUG_DROPPED") # Do this last
			
