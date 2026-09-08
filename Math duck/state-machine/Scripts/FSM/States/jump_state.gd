extends State

@export var idle_state: State
@export var move_state: State
@export var dash_state: State

@onready var chicken: CharacterBody2D = owner as CharacterBody2D
@onready var texture = chicken.get_node_or_null("Sprite2D")

func enter_state():
	if chicken:
		chicken.velocity.y = chicken.JUMP_VELOCITY
		
func update(_delta: float) -> void:
	if chicken.is_on_floor():
		switch_state.emit(idle_state)
		
	elif Input.is_action_just_pressed("dash") and chicken and chicken.can_dash:
		switch_state.emit(dash_state)
		
func physics_update(_delta:float) -> void:
	var input_x = Input.get_axis("ui_left", "ui_right")
	
	_move(_delta, input_x)
	update_animation(input_x)
	
	if chicken:
		chicken.move_and_slide()
func _move(_delta:float, input_x: float) -> void:
	if chicken:
		chicken.velocity.x = input_x * chicken.SPEED
		
		chicken.velocity.y += chicken.get_gravity().y * _delta
		
func update_animation(input_x: float) -> void:
	if texture and input_x != 0:
		texture.flip_h = (input_x < 0)

func enter() -> void:
	if chicken:
		chicken.velocity.y = chicken.JUMP_VELOCITY
		chicken.consume_coyote_time()
