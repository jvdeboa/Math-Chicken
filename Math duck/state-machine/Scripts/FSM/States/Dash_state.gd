extends State

@export var idle_state: State
@export var move_state: State

@onready var chicken: CharacterBody2D = owner as CharacterBody2D
@onready var texture: Sprite2D = owner.get_node_or_null("Sprite2D")

func enter_state() -> void:
	if chicken:
		chicken.dash_timer = chicken.dash_duration
		chicken.can_dash = false
		_cooldown()

func update(_delta: float) -> void:
	if chicken:
		chicken.dash_timer -= _delta
		
		if chicken.dash_timer <= 0:
			if Input.get_axis("ui_left", "ui_right") != 0:
				switch_state.emit(move_state)
			else:
				switch_state.emit(idle_state)

func _cooldown() -> void:
	await get_tree().create_timer(chicken.dash_cooldown).timeout
	if chicken:
		chicken.can_dash = true

func physics_update(_delta: float) -> void:
	_move(_delta)
	if chicken:
		chicken.move_and_slide()

func _move(_delta: float) -> void:
	if chicken:
		var direction = -1.0 if (texture and texture.flip_h) else 1.0
		
		chicken.velocity.x = chicken.dash_force * direction
		chicken.velocity.y = 0.0  # Trava a gravidade no ar durante o dash
