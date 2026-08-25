extends State

@export var idle_state: State
@export var dash_state: State
@export var jump_state: State
@export var _animation: AnimationPlayer

@onready var chicken: CharacterBody2D = owner as CharacterBody2D
@onready var texture: Sprite2D = owner.get_node_or_null("Sprite2D")

func enter_state() -> void:
	if _animation:
		_animation.play("Run")

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and chicken.is_on_floor():
		switch_state.emit(jump_state)
		return 
		
	if Input.is_action_just_pressed("dash") and chicken and chicken.can_dash:
		switch_state.emit(dash_state)
		return
		
	if Input.get_axis("ui_left", "ui_right") == 0:
		switch_state.emit(idle_state)

func physics_update(_delta: float) -> void:
	var input_x = Input.get_axis("ui_left", "ui_right")
	
	_move(_delta, input_x)
	update_animation(input_x)
	
	chicken.move_and_slide()

func _move(_delta: float, input_x: float) -> void:
	if chicken:
		chicken.velocity.x = input_x * chicken.SPEED
		
		if not chicken.is_on_floor():
			chicken.velocity.y += chicken.get_gravity().y * _delta

func update_animation(input_x: float) -> void:
	if texture and input_x != 0:
		texture.flip_h = (input_x < 0)
