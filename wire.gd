class_name Wire extends Path2D

var held: bool = false
var origin: Plug = null
var receiver: Plug = null

func _process(delta: float) -> void:
	if self.held:
		var mouse_position: Vector2 = get_viewport().get_mouse_position() / 2.0
		self.curve.set_point_position(0, origin.position)
		var outX: float = mouse_position.x / 2
		self.curve.set_point_out(0, Vector2(0, outX))
		
		self.curve.set_point_position(1, mouse_position)
		self.curve.set_point_in(1, Vector2(0, outX))
		self.queue_redraw()
	else: 
		self.curve.set_point_position(0, origin.position)
		var outX: float = receiver.position.x / 2
		self.curve.set_point_out(0, Vector2(0, outX))
		
		self.curve.set_point_position(1, receiver.position)
		self.curve.set_point_in(1, Vector2(0, outX))
		self.queue_redraw()

func _draw() -> void:
	draw_polyline(self.curve.get_baked_points(), Color.WHITE, 0.5, false)
	
func request_delete() -> void:
	self.origin.wires_to_erase.append(self)
