extends CharacterBody3D

@export var SPEED: float = 5.0
@export var ANGULAR_SPEED: float = 60.0 # degrees

const DEG_90: float = deg_to_rad(90)
const DEG_180: float = deg_to_rad(180)

@onready var forward_signal: bool = false
@onready var backward_signal: bool = false
@onready var left_strafe_signal: bool = false
@onready var right_strafe_signal: bool = false
@onready var left_rotate_signal: bool = false
@onready var right_rotate_signal: bool = false 

@onready var facing_direction: Vector2 = Vector2(1, 0)

func _ready() -> void:
	SignalBus.connect("MECH_FORWARD_SIGNAL_ON", _on_forward_signal_on)
	SignalBus.connect("MECH_FORWARD_SIGNAL_OFF", _on_forward_signal_off)
	SignalBus.connect("MECH_BACKWARD_SIGNAL_ON", _on_backward_signal_on)
	SignalBus.connect("MECH_BACKWARD_SIGNAL_OFF", _on_backward_signal_off)
	SignalBus.connect("MECH_LEFT_STRAFE_SIGNAL_ON", _on_left_strafe_signal_on)
	SignalBus.connect("MECH_LEFT_STRAFE_SIGNAL_OFF", _on_left_strafe_signal_off)
	SignalBus.connect("MECH_RIGHT_STRAFE_SIGNAL_ON", _on_right_strafe_signal_on)
	SignalBus.connect("MECH_RIGHT_STRAFE_SIGNAL_OFF", _on_right_strafe_signal_off)
	SignalBus.connect("MECH_LEFT_ROTATE_SIGNAL_ON", _on_left_rotate_signal_on)
	SignalBus.connect("MECH_LEFT_ROTATE_SIGNAL_OFF", _on_left_rotate_signal_off)
	SignalBus.connect("MECH_RIGHT_ROTATE_SIGNAL_ON", _on_right_rotate_signal_on)
	SignalBus.connect("MECH_RIGHT_ROTATE_SIGNAL_OFF", _on_right_rotate_signal_off)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# forwards and backwards strafe
	var forward_input_mov: int = 0
	if forward_signal:
		forward_input_mov += 1
	if backward_signal:
		forward_input_mov += -1
	
	# left and right strafe
	var lateral_input_mov: int = 0
	if right_strafe_signal:
		lateral_input_mov += 1
	if left_strafe_signal:
		lateral_input_mov += -1
		
	var input_rot: int = 0
	if right_rotate_signal:
		input_rot += 1
	if left_rotate_signal:
		input_rot += -1 
	
	# planar movement 
	var planar_movement: Vector2 = Vector2(lateral_input_mov, forward_input_mov).normalized()\
		.rotated(facing_direction.normalized().angle())
	if planar_movement.length() != 0:
		velocity.x = planar_movement.x * SPEED 
		velocity.z = -planar_movement.y * SPEED
	else:
		velocity.x = 0
		velocity.z = 0
	
	# rotation
	if input_rot != 0:
		var rot_difference: float = deg_to_rad(ANGULAR_SPEED) * -input_rot * delta
		facing_direction = facing_direction.rotated(rot_difference)
		rotate_y(rot_difference)
	
	move_and_slide()
	
func _on_forward_signal_on() -> void:
	forward_signal = true
	
func _on_forward_signal_off() -> void:
	forward_signal = false
	
func _on_backward_signal_on() -> void:
	backward_signal = true
	
func _on_backward_signal_off() -> void:
	backward_signal = false
	
func _on_left_strafe_signal_on() -> void:
	left_strafe_signal = true
	
func _on_left_strafe_signal_off() -> void:
	left_strafe_signal = false
	
func _on_right_strafe_signal_on() -> void:
	right_strafe_signal = true
	
func _on_right_strafe_signal_off() -> void:
	right_strafe_signal = false 
	
func _on_left_rotate_signal_on() -> void:
	left_rotate_signal = true
	
func _on_left_rotate_signal_off() -> void:
	left_rotate_signal = false
	
func _on_right_rotate_signal_on() -> void:
	right_rotate_signal = true
	
func _on_right_rotate_signal_off() -> void:
	right_rotate_signal = false
