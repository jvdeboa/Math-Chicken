extends CharacterBody2D

@export_group("Player Configuration")
@export var SPEED: float = 200.0
@export var JUMP_VELOCITY: float = -250.0

@export_group("Jump Configuration")
@export var coyote_time: float = 0.10
var coyote_timer: float = 0.0

@export_group("Dash Configuration")
@export var dash_force: float = 300.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var dash_timer: float = 0.0
var can_dash: bool = true

func _physics_process(delta: float) -> void:
	# Reseta o timer se estiver no chão; caso contrário, conta o tempo de queda
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	move_and_slide()

# Verifica se o jogador ainda pode pular dentro da janela do Coyote Time
func can_coyote_jump() -> bool:
	return coyote_timer > 0.0

# Zera o timer ao pular para evitar pulos duplos acidentais
func consume_coyote_time() -> void:
	coyote_timer = 0.0
