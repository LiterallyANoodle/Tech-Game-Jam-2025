extends Node

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
