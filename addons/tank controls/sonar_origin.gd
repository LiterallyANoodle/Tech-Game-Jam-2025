class_name SonarOrigin extends Node3D

@export var rays: int = 100
@export var rotation_time: float = 3.0

@onready var angular_speed: float = 2.0*PI / rotation_time
@onready var query_rate: float = rotation_time / rays
@onready var raycast_rotation: float = 0.0

var time_since_query: float = 0.0

func _physics_process(delta: float) -> void:
	time_since_query += delta
	if time_since_query >= query_rate:
		var query = PhysicsRayQueryParameters3D.create(global_position, \
			Vector3.FORWARD.rotated(Vector3.UP, raycast_rotation) * 100.0,
			2)
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		if result.has("position"):
			SignalBus.emit_signal("SONAR_WALL_PINGED", to_local(result["position"]))
	raycast_rotation = fmod(raycast_rotation + (angular_speed * delta), 2.0*PI)
	
