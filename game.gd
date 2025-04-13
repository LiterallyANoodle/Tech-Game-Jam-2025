extends Node

@export var arrow_cursor: Resource = load("res://hand_ungrab.png")
@export var drag_cursor: Resource = load("res://hand_grab.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2(6, 18))
	Input.set_custom_mouse_cursor(drag_cursor, Input.CURSOR_DRAG, Vector2(6, 18))
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_released():
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
