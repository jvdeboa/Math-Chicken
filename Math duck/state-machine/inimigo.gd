extends CharacterBody2D

var speed = 100
var direction = 1
var gravity = 980

func _physics_process(delta):
	# 1. Aplicar gravidade (apenas se não estiver no chão)
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Calcular movimento horizontal
	velocity.x = direction * speed

	# 3. Executar o movimento
	move_and_slide()

	# 4. Lógica de detecção de barreira
	if $RayWall.is_colliding() or not $RayEdge.is_colliding():
		direction *= -1
		$AnimatedSprite2D.flip_h = direction == -1
		$RayWall.target_position.x *= -1 
		$RayEdge.position.x *= -1

# 5. O SEGREDO ESTÁ AQUI: Passar a posição (x) do inimigo para a galinha
func _on_hitbox_body_entered(body):
	if body.is_in_group("jogador"):
		if body.has_method("tomar_dano"):
			# Envia a posição do espinho para a galinha saber para onde voar!
			body.tomar_dano(global_position.x)
