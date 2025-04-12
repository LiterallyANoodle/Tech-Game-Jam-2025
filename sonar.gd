extends Control

@onready var dots_texture: Resource = preload("res://dot.tres")
@onready var reference: Polygon2D = $SubViewportContainer/SubViewport/Polygon2D
@onready var dots_array: Array = []

func _ready() -> void:
	SignalBus.connect("SONAR_WALL_PINGED", _on_sonar_wall_pinged)
	
func _on_sonar_wall_pinged(ray_position: Vector3) -> void:
	var dot: Sprite2D = Sprite2D.new()
	dot.set_texture(dots_texture)
	dot.global_position = reference.offset + (Vector2(ray_position.x, ray_position.z) * 50)
	dots_array.append(dot)
	reference.add_child(dot)
