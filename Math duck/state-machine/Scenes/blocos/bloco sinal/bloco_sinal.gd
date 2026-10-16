extends Area2D

@export var simbolo_manual: String = ""
var valor_do_bloco: String = ""

@onready var label: Label = $Label

func _ready() -> void:
	if simbolo_manual == "":
		valor_do_bloco = str(randi_range(0, 9))
	else:
		valor_do_bloco = simbolo_manual
	
	# Se for o sinal de vezes, aplicamos a correção visual!
	if valor_do_bloco == "x":
		label.text = "X" # Usa o X maiúsculo
		
		# Garante que temos as configurações de texto para modificar
		var estilo = label.label_settings
		if estilo == null:
			estilo = LabelSettings.new() # Cria uma configuração nova do zero
		else:
			estilo = estilo.duplicate() # Ou clona a existente
			
		estilo.font = null # Remove a fonte pixelada
		estilo.font_size = 22 # Força o tamanho correto!
		
		# --- ADICIONE ESTA LINHA PARA FORÇAR A COR PRETA ---
		estilo.font_color = Color(0, 0, 0) 
		
		label.label_settings = estilo
		label.remove_theme_font_override("font")
			
		# Centraliza perfeitamente o texto no meio do quadrado
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			
	else:
		# Se for número, + ou -, usa o texto normal com a fonte pixelada
		label.text = valor_do_bloco
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Garante que APENAS a galinha apanha blocos (e não os inimigos)
	if body.is_in_group("jogador"):
		
		# Impede a recolha acidental enquanto a galinha sofre dano e voa
		if body.invulneravel:
			return
			
		# Grita para o Gerenciador passando as 3 informações!
		get_tree().call_group("gerenciador", "registrar_coleta", valor_do_bloco, global_position, body)
		queue_free()
