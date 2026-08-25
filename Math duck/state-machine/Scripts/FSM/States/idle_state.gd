extends State

@export var move_state: State
@export var dash_state: State
@export var jump_state: State
@export var _animation: AnimationPlayer
@onready var chicken: CharacterBody2D = owner as CharacterBody2D

func enter_state() -> void:
	if _animation:
		_animation.play("Idle")
	
func update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and chicken and chicken.can_coyote_jump():
		switch_state.emit(jump_state)
		return
		
	if Input.is_action_just_pressed("dash") and chicken and chicken.can_dash:
		switch_state.emit(dash_state)
		return
		
	if Input.get_axis("ui_left", "ui_right") != 0:
		switch_state.emit(move_state)
		
func physics_update(_delta:float) -> void:
	
	_move(_delta)
	
	chicken.move_and_slide()
	
func _move(_delta:float) -> void:
	chicken.velocity.x = move_toward(chicken.velocity.x, 0, 300.0)
	
	if not chicken.is_on_floor():
		chicken.velocity.y += chicken.get_gravity().y * _delta
