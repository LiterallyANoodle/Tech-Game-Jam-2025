class_name Plug extends Sprite2D

enum SignalType {VIDEO_IN, VIDEO_OUT, POWER_IN, POWER_OUT}
enum VideoOut {OCULAR, SONAR, INFORMATION, PROXIMITY, STATUS}

@export var signal_type: SignalType = SignalType.POWER_OUT
@export var video_output: VideoOut = VideoOut.SONAR
@export var label_text: String = ""

var connections: Array = []
var connections_to_erase: Array = []
var incoming_power_level: int = 0
var incoming_video_signals: Array = []
var wires: Array = []
var wires_to_erase: Array = []

func _process(delta: float) -> void:
	
	# destroy deleted connections 
	for p: Plug in connections_to_erase:
		connections.erase(p)
	connections_to_erase = []
	for w: Wire in wires_to_erase:
		wires.erase(w)
		w.queue_free()
	wires_to_erase = []

# when the origin plug is notified which plug its wire has been released on
func connection_acknowledge(other: Plug) -> void:
	if other != self and other not in connections:
		connections.append(other)
		for w: Wire in wires:
			if w.held:
				w.receiver = other
				w.held = false
		print(self.name, " ", connections)
	
func connection_delete(other: Plug) -> void:
	# have to delay actual erasure because it will fuck with the control flow
	connections_to_erase.append(other)
	for w: Wire in wires:
		if w.receiver == other and w.origin == self:
			wires_to_erase.append(w)
			
func _on_area_2d_mouse_entered() -> void:
	SignalBus.emit_signal("PLUG_HOVERED", self)

func _on_area_2d_mouse_exited() -> void:
	SignalBus.emit_signal("PLUG_UNHOVERED", self)
