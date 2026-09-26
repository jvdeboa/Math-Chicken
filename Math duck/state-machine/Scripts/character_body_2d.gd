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
var vidas = 3
var invulneravel = false 
var posicao_inicial: Vector2 # <-- Vai guardar onde a galinha nasce

# ATENÇÃO: Verifique se o caminho abaixo aponta corretamente para a sua CENA (.tscn) e não para o script (.gd)
const MENU_GAME_OVER = preload("res://menu_game_over.tscn")

func _ready():
	# Assim que a fase começa, salvamos o lugar exato onde a galinha está
	posicao_inicial = global_position

func _physics_process(delta: float) -> void:
	if invulneravel:
		velocity.y += 980 * delta 
		move_and_slide()
		return 

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	move_and_slide()

func can_coyote_jump() -> bool:
	return coyote_timer > 0.0

func consume_coyote_time() -> void:
	coyote_timer = 0.0
	
func tomar_dano(posicao_inimigo_x, quantidade_dano = 1, voltar_pro_inicio = false):
	if invulneravel:
		return 

	vidas -= quantidade_dano
	print("Ai! Vidas restantes: ", vidas)
	
	get_tree().call_group("hud_vidas", "atualizar_vidas", vidas)

	invulneravel = true

	if has_node("StateMachine"):
		$StateMachine.process_mode = Node.PROCESS_MODE_DISABLED

	velocity.y = -300 
	
	if global_position.x < posicao_inimigo_x:
		velocity.x = -400 
	else:
		velocity.x = 400  

	modulate.a = 0.5 
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation + deg_to_rad(360), 0.5)

	await get_tree().create_timer(0.5).timeout

	# --- NOVO SISTEMA DE GAME OVER ---
	if vidas <= 0:
		# Instancia o menu de morte e adiciona-o ao ecrã
		var tela_morte = MENU_GAME_OVER.instantiate()
		get_parent().add_child(tela_morte)
		
		# Pausa o jogo (congela tempo, gravidade, inimigos, etc.)
		get_tree().paused = true 
		return

	# SE SOBREVIVEU, mas tomou dano de um espinho de parkour:
	if voltar_pro_inicio:
		global_position = posicao_inicial # Teletransporta de volta pro começo!
		velocity = Vector2.ZERO # Zera a velocidade do pulo pra ela não sair voando

	if has_node("StateMachine"):
		$StateMachine.process_mode = Node.PROCESS_MODE_INHERIT
		
	modulate.a = 1.0
	rotation = 0 
	invulneravel = false
