extends Control

@export var time_to_live: float = 3.0

@onready var dots_texture: Resource = preload("res://dot.tres")
@onready var reference: Polygon2D = $SubViewportContainer/SubViewport/Polygon2D
@onready var dots_dict: Dictionary = {} # stores {dot: time_created} for quick calcs

func _ready() -> void:
	SignalBus.connect("SONAR_WALL_PINGED", _on_sonar_wall_pinged)
	
func _physics_process(delta: float) -> void:
	var time: int = Time.get_ticks_msec()
	var destroy_dots: Array = []
	for dot: Sprite2D in dots_dict:
		var ttl_ratio: float = (time - dots_dict[dot]) / (time_to_live * 1000) # how far in its life 
		dot.modulate.a = 0.9 - ttl_ratio
		if ttl_ratio >= 1.0:
			destroy_dots.append(dot)
	# im unsure how deleting the dots in the for loop might fuck with the control flow, so it's separate
	for dot: Sprite2D in destroy_dots:
		dots_dict.erase(dot)
		dot.queue_free()
	
func _on_sonar_wall_pinged(ray_position: Vector3) -> void:
	var dot: Sprite2D = Sprite2D.new()
	dot.set_texture(dots_texture)
	dot.global_position = reference.offset + (Vector2(ray_position.x, ray_position.z) * 50)
	dots_dict[dot] = Time.get_ticks_msec()
	reference.add_child(dot)
