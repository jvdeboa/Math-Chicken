extends CanvasLayer # (Mantenha o "extends" que já estava no seu script, pode ser Control ou Node2D)

func atualizar_vidas(vidas_restantes):
	print("removendo sprite de coracao, vidas restantes: ", vidas_restantes)
	
	# Como vimos na foto que o caminho é este, fomos diretos ao assunto:
	$HBoxContainer/Coracao1.visible = vidas_restantes >= 1
	$HBoxContainer/Coracao2.visible = vidas_restantes >= 2
	$HBoxContainer/Coracao3.visible = vidas_restantes >= 3
