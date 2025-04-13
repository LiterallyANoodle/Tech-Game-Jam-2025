extends Node

@onready var char: Node = get_tree().root.get_node_or_null("/root/Level/Character")
@onready var cam: Camera3D = char.find_child("Camera3D")

func _input(event: InputEvent) -> void:
	# mech ambulation 
	if event.is_action_pressed("up"):
		SignalBus.emit_signal("MECH_FORWARD_SIGNAL_ON")
	if event.is_action_released("up"):
		SignalBus.emit_signal("MECH_FORWARD_SIGNAL_OFF")
	if event.is_action_pressed("down"):
		SignalBus.emit_signal("MECH_BACKWARD_SIGNAL_ON")
	if event.is_action_released("down"):
		SignalBus.emit_signal("MECH_BACKWARD_SIGNAL_OFF")
	if event.is_action_pressed("left"):
		SignalBus.emit_signal("MECH_LEFT_STRAFE_SIGNAL_ON")
	if event.is_action_released("left"):
		SignalBus.emit_signal("MECH_LEFT_STRAFE_SIGNAL_OFF")
	if event.is_action_pressed("right"):
		SignalBus.emit_signal("MECH_RIGHT_STRAFE_SIGNAL_ON")
	if event.is_action_released("right"):
		SignalBus.emit_signal("MECH_RIGHT_STRAFE_SIGNAL_OFF")
	if event.is_action_pressed("q"):
		SignalBus.emit_signal("MECH_LEFT_ROTATE_SIGNAL_ON")
	if event.is_action_released("q"):
		SignalBus.emit_signal("MECH_LEFT_ROTATE_SIGNAL_OFF")
	if event.is_action_pressed("e"):
		SignalBus.emit_signal("MECH_RIGHT_ROTATE_SIGNAL_ON")
	if event.is_action_released("e"):
		SignalBus.emit_signal("MECH_RIGHT_ROTATE_SIGNAL_OFF")
		
	# menuing 
	if event.is_action_pressed("esc"):
		get_tree().quit(0)
		
	# 3d camera
	if event.is_action_pressed("equals"):
		if char == null:
			print("Can't manipulate camera! No Character!")
		else:
			if cam == null:
				cam = Camera3D.new()
				cam.fov = 90
				cam.position.y = 1.5
				char.add_child(cam)
			else:
				cam.queue_free()
