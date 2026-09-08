extends Camera2D

@export var top_left: Marker2D
@export var bottom_right: Marker2D

func _ready() -> void:
	_fit_to_room()

func _fit_to_room() -> void:
	var room_size: Vector2 = bottom_right.position - top_left.position
	var viewport_size: Vector2 = get_viewport_rect().size

	position = top_left.position + room_size / 2.0
	zoom = Vector2.ONE * max(
		room_size.x / viewport_size.x,
		room_size.y / viewport_size.y
	)
