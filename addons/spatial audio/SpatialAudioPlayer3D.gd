class_name SpatialAudioPlayer3D extends AudioStreamPlayer3D

@export var max_raycast_distace: float = 30.0
@export var update_frequency_seconds: float = 0.05
@export var lerp_speed: float = 1.0
@export_group("Effects")
@export var max_reverb_wetness: float = 0.5
@export var wall_lowpass_cutoff_amount: int = 600

var _raycast_array: Array = []
var _distance_array: Array = [0,0,0,0,0,0,0,0,0,0]
var _last_update_time: float = 0.0
var _update_distances: bool = true
var _current_raycast_index: int = 0

# Audio bus this spatial player plays through
var _audio_bus_index = null
var _audio_bus_name = ""

# Effects 
var _reverb_effect: AudioEffectReverb
var _lowpass_filter: AudioEffectLowPassFilter

# Target parameters for lerp
var _target_lowpass_cutoff: float = 20_000
var _target_reverb_room_size: float = 0.0
var _target_reverb_wetness: float = 0.0
var _target_volume_db: float = 0.0

func _ready() -> void:
	# Create audio bus to interact with effects
	_audio_bus_index = AudioServer.bus_count
	_audio_bus_name = "SpatialBus#"+str(_audio_bus_index)
	AudioServer.add_bus(_audio_bus_index)
	AudioServer.set_bus_name(_audio_bus_index, _audio_bus_name)
	AudioServer.set_bus_send(_audio_bus_index, bus)
	self.bus = _audio_bus_name
	
	# Add effects to bus
	AudioServer.add_bus_effect(_audio_bus_index, AudioEffectReverb.new(), 0)
	_reverb_effect = AudioServer.get_bus_effect(_audio_bus_index, 0)
	AudioServer.add_bus_effect(_audio_bus_index, AudioEffectLowPassFilter.new(), 1)
	_lowpass_filter = AudioServer.get_bus_effect(_audio_bus_index, 1)
	
	# Capture target volume, and lerp from silent to target
	_target_volume_db = volume_db
	volume_db = -60.0
	
	# Initialize raycast distances
	$Down.target_position = Vector3(0, -max_raycast_distace, 0)
	$Left.target_position = Vector3(max_raycast_distace, 0, 0)
	$Right.target_position = Vector3(-max_raycast_distace, 0, 0)
	$Forward.target_position = Vector3(0, 0, max_raycast_distace)
	$ForwardLeft.target_position = Vector3(0, 0, max_raycast_distace)
	$ForwardRight.target_position = Vector3(0, 0, max_raycast_distace)
	$BackwardLeft.target_position = Vector3(0, 0, -max_raycast_distace)
	$BackwardRight.target_position = Vector3(0, 0, -max_raycast_distace)
	$Backward.target_position = Vector3(0, 0, -max_raycast_distace)
	$Up.target_position = Vector3(0, max_raycast_distace, 0)
	$LineOfSight.target_position = Vector3(0, 0, max_raycast_distace)
	
	_raycast_array.append($Down)
	_raycast_array.append($Left)
	_raycast_array.append($Right)
	_raycast_array.append($Forward)
	_raycast_array.append($ForwardLeft)
	_raycast_array.append($ForwardRight)
	_raycast_array.append($BackwardRight)
	_raycast_array.append($BackwardLeft)
	_raycast_array.append($Backward)
	_raycast_array.append($Up)
	
func _on_update_raycast_distace(raycast: RayCast3D, raycast_index: int) -> void:
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider != null:
		_distance_array[raycast_index] = self.global_position.distance_to(raycast.get_collision_point())
	else: 
		_distance_array[raycast_index] = -1
	raycast.enabled = false # raycast should not run all the time
	
func _on_update_spatial_audio(player: Node3D) -> void:
	_on_update_reverb(player)
	_on_update_lowpass_filter(player)
	
func _on_update_reverb(_player: Node3D) -> void: 
	if _reverb_effect != null:
		var room_size = 0.0
		var wetness = 1.0
		for dist in _distance_array:
			if dist >= 0:
				room_size += (dist / max_raycast_distace) / (float(_distance_array.size()))
				room_size = min(room_size, 1.0)
			else: 
				wetness -= 1.0 / float(_distance_array.size())
				wetness = max(wetness, 0.0)
		_target_reverb_wetness = wetness
		_target_reverb_room_size = room_size
	
func _on_update_lowpass_filter(_player: Node3D) -> void:
	if _lowpass_filter != null:
		var query = PhysicsRayQueryParameters3D.create(self.global_position, \
			self.global_position + (_player.global_position - self.global_position).normalized() * max_raycast_distace, \
			$Forward.get_collision_mask())
		var space_state = get_world_3d().direct_space_state
		var result = space_state.intersect_ray(query)
		var lowpass_cutoff = 20_000 # init with no cutoff 
		if !result.is_empty():
			var ray_distace = self.global_position.distance_to(result["position"])
			var distance_to_player = self.global_position.distance_to(_player.global_position)
			var wall_to_player_ratio = ray_distace / max(distance_to_player, 0.001)
			if ray_distace < distance_to_player:
				lowpass_cutoff = wall_lowpass_cutoff_amount * wall_to_player_ratio
		_target_lowpass_cutoff = lowpass_cutoff

func _lerp_parameters() -> void:
	volume_db = move_toward(volume_db, _target_volume_db, lerp_speed)
	_lowpass_filter.cutoff_hz = move_toward(_lowpass_filter.cutoff_hz, _target_lowpass_cutoff, lerp_speed * 1500.0)
	_reverb_effect.wet = move_toward(_reverb_effect.wet, _target_reverb_wetness * max_reverb_wetness, lerp_speed * 5.0)
	_reverb_effect.room_size = move_toward(_reverb_effect.room_size, _target_reverb_room_size, lerp_speed * 5.0)
	
func _physics_process(delta: float) -> void:
	_last_update_time += delta
	
	if _update_distances:
		_on_update_raycast_distace(_raycast_array[_current_raycast_index], _current_raycast_index)
		_current_raycast_index += 1
		if _current_raycast_index >= _distance_array.size():
			_current_raycast_index = 0
			_update_distances = false
			
	if _last_update_time > update_frequency_seconds:
		var player_camera = get_viewport().get_camera_3d() # assumes player is the current active camera
		if player_camera != null:
			_on_update_spatial_audio(player_camera)
		_update_distances = true
		_last_update_time = 0.0
		
	_lerp_parameters()
