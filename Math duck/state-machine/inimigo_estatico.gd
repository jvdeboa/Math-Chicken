extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jogador"):
		if body.has_method("tomar_dano"):
			# Envia: a posição, 1 de dano, e "true" para teletransportar de volta pro começo
			body.tomar_dano(global_position.x, 1, true)
