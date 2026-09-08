extends State

@export var idle_state: State
@export var move_state: State

@onready var chicken: CharacterBody2D = owner as CharacterBody2D
@onready var texture: Sprite2D = owner.get_node_or_null("Sprite2D")

var ghost_timer: float = 0.0
@export var ghost_delay: float = 0.03 # Frequência dos rastros

func enter_state() -> void:
	if chicken:
		chicken.dash_timer = chicken.dash_duration
		chicken.can_dash = false
		ghost_timer = 0.0
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
	
	ghost_timer -= _delta
	if ghost_timer <= 0.0:
		_spawn_ghost()
		ghost_timer = ghost_delay

	if chicken:
		chicken.move_and_slide()

func _move(_delta: float) -> void:
	if chicken:
		var direction = -1.0 if (texture and texture.flip_h) else 1.0
		
		chicken.velocity.x = chicken.dash_force * direction
		chicken.velocity.y = 0.0

func _spawn_ghost() -> void:
	# 1. Checa se o Sprite e o Personagem existem ANTES de tudo
	if not texture or not chicken:
		print("ERRO: Falta textura ou referência ao chicken no dash_state!")
		return
		
	# 2. Cria a cópia do Sprite2D
	var ghost = Sprite2D.new()
	ghost.texture = texture.texture
	ghost.hframes = texture.hframes
	ghost.vframes = texture.vframes
	ghost.frame = texture.frame
	ghost.flip_h = texture.flip_h
	ghost.global_position = texture.global_position
	ghost.scale = texture.global_scale
	
	# Cor e transparência inicial do borral
	ghost.modulate = Color(0.3, 0.6, 1.0, 0.6)
	
	# 3. Anexa o script e força a execução do _ready()
	ghost.set_script(preload("res://Main Character/dash_ghost.gd"))
	ghost._ready()
	
	# 4. Adiciona o rastro na cena principal
	get_tree().current_scene.add_child(ghost)
