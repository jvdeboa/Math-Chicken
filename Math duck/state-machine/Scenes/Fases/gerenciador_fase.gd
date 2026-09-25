extends Node

@export var cena_bloco_numeral: PackedScene
@export var cena_bloco_sinal: PackedScene
@export var grupo_spawn_points: Node2D
@export var nivel_dificuldade: int = 1
@export var texto_hud: Label
@export var texto_tempo: Label
@export var tempo_maximo: float = 30.0
@export var efeito_confete: CPUParticles2D

var resultado_esperado: int = 0
var tempo_restante: float = 0.0
var blocos_coletados: Array[String] = []
var equacao_correta: Array[String] = [] # Guarda a ordem exata que o jogador tem de apanhar
var quantidade_necessaria: int = 3
var blocos_no_mapa: Array[String] = []
var jogo_terminou: bool = false

func _ready() -> void:
	add_to_group("gerenciador")
	tempo_restante = tempo_maximo
	gerar_nova_equacao()
	atualizar_hud()
	
func _process(delta: float) -> void:
	# Se o jogo já acabou (vitória ou morte), o relógio pára
	if jogo_terminou: return
	
	if tempo_restante > 0:
		tempo_restante -= delta # Subtrai o tempo que passou desde a última frame
		
		if texto_tempo:
			# Magia do texto: "%.2f" força o número a ter sempre 2 casas decimais (ex: 10.23)
			texto_tempo.text = "%.2f" % tempo_restante 
	else:
		# ACABOU O TEMPO!
		tempo_restante = 0.0
		if texto_tempo: texto_tempo.text = "0.00"
		
		jogo_terminou = true
		print("Tempo Esgotado!")
		
		# Encontra a galinha no mapa através do grupo que criámos no Passo 1
		var jogador = get_tree().get_first_node_in_group("jogador")
		if jogador:
			matar_jogador(jogador)

func gerar_nova_equacao() -> void:
	var quantidade_numeros: int = 2
	var operacoes_permitidas: Array = []
	var quantidade_iscos: int = 0
	
	match nivel_dificuldade:
		1: 
			quantidade_numeros = 2
			operacoes_permitidas = ["+"]
			quantidade_iscos = 1 
			quantidade_necessaria = 3
		2: 
			quantidade_numeros = 2
			operacoes_permitidas = ["+", "-", "x"]
			quantidade_iscos = 2 
			quantidade_necessaria = 3
		3: 
			quantidade_numeros = 3
			operacoes_permitidas = ["+", "-", "x"]
			quantidade_iscos = 2 
			quantidade_necessaria = 5 
			
	var numeros_certos: Array = []
	for i in range(quantidade_numeros):
		numeros_certos.append(randi_range(1, 9))
		
	var operadores_certos: Array = []
	for i in range(quantidade_numeros - 1):
		operadores_certos.append(operacoes_permitidas.pick_random())
		
	# SALVA A ORDEM CORRETA PARA VERIFICAR DEPOIS
	equacao_correta.clear()
	for i in range(numeros_certos.size()):
		equacao_correta.append(str(numeros_certos[i]))
		if i < operadores_certos.size():
			equacao_correta.append(operadores_certos[i])
			
	resultado_esperado = calcular_resultado(numeros_certos, operadores_certos)
	
	var blocos_para_criar: Array[String] = []
	blocos_para_criar.append_array(equacao_correta)
		
	for i in range(quantidade_iscos):
		blocos_para_criar.append(str(randi_range(0, 9)))
		
	if nivel_dificuldade >= 2:
		var sinais_falsos = ["+", "-", "x"]
		blocos_para_criar.append(sinais_falsos.pick_random())
		
	var qtd_markers = grupo_spawn_points.get_child_count()
	if blocos_para_criar.size() > qtd_markers:
		blocos_para_criar.resize(qtd_markers)
		
	blocos_para_criar.shuffle()
	blocos_no_mapa = blocos_para_criar.duplicate()
	espalhar_blocos(blocos_para_criar)

func calcular_resultado(numeros: Array, operadores: Array) -> int:
	var nums = numeros.duplicate()
	var ops = operadores.duplicate()
	var i = 0
	while i < ops.size():
		if ops[i] == "x":
			nums[i] = nums[i] * nums[i+1]
			nums.remove_at(i+1)
			ops.remove_at(i)
		else:
			i += 1
			
	var resultado = nums[0]
	for j in range(ops.size()):
		if ops[j] == "+":
			resultado += nums[j+1]
		elif ops[j] == "-":
			resultado -= nums[j+1]
	return resultado

func espalhar_blocos(blocos: Array[String]) -> void:
	var pontos_disponiveis = grupo_spawn_points.get_children()
	pontos_disponiveis.shuffle()
	
	for i in range(blocos.size()):
		if i >= pontos_disponiveis.size(): break
		
		var valor_atual = blocos[i]
		var novo_bloco: Area2D
		if valor_atual in ["+", "-", "x"]: novo_bloco = cena_bloco_sinal.instantiate()
		else: novo_bloco = cena_bloco_numeral.instantiate()
			
		novo_bloco.simbolo_manual = valor_atual 
		novo_bloco.global_position = pontos_disponiveis[i].global_position
		novo_bloco.add_to_group("blocos_fase")
		get_parent().add_child.call_deferred(novo_bloco)

# --- SISTEMA DE HUD E VALIDAÇÃO PRECOCE ---

func registrar_coleta(valor_coletado: String, pos_bloco: Vector2, jogador: CharacterBody2D) -> void:
	if jogo_terminou: return # Se o jogo já acabou, ignora qualquer toque!
	
	blocos_coletados.append(valor_coletado)
	blocos_no_mapa.erase(valor_coletado)
	animar_bloco_para_hud(valor_coletado, pos_bloco)
	
	# 1. Morte por Sintaxe
	var indice = blocos_coletados.size() - 1
	var is_numero = valor_coletado.is_valid_int()
	if (indice % 2 == 0 and not is_numero) or (indice % 2 != 0 and is_numero):
		print("Morreu! O jogo esperava um ", "número" if indice % 2 == 0 else "sinal")
		jogo_terminou = true # <--- TRANCA IMEDIATAMENTE
		matar_jogador(jogador)
		return

	# 2. Quando a equação está completa
	if blocos_coletados.size() == quantidade_necessaria:
		jogo_terminou = true # <--- A SOLUÇÃO AQUI! Tranca o jogo ANTES da pausa de 0.5s!
		jogador.set_physics_process(false)
		
		# Agora podemos esperar em paz, porque a trava lá em cima vai impedir novas coletas
		await get_tree().create_timer(0.5).timeout 
		
		if avaliar_expressao(blocos_coletados) == float(resultado_esperado):
			print("VITÓRIA!")
			if efeito_confete:
				efeito_confete.global_position = jogador.global_position
				efeito_confete.emitting = true
				
			get_tree().call_group("portal", "activate")
			limpar_blocos_restantes()
			jogador.set_physics_process(true)
		else:
			print("Morreu! O resultado final estava errado.")
			matar_jogador(jogador)
			
	# 3. O Jogo Simula o Futuro
	else:
		if not tem_solucao_futura(blocos_coletados, blocos_no_mapa):
			print("Morreu cedo! Nenhuma combinação com os blocos restantes dará ", resultado_esperado)
			jogo_terminou = true # <--- TRANCA IMEDIATAMENTE
			matar_jogador(jogador)

func tem_solucao_futura(coletados: Array, disponiveis: Array) -> bool:
	var faltam = quantidade_necessaria - coletados.size()
	
	# Se a simulação chegou ao fim dos espaços, verifica se essa linha do tempo está certa
	if faltam == 0:
		return avaliar_expressao(coletados) == float(resultado_esperado)

	# Tenta preencher o próximo espaço com todos os blocos que sobraram
	for i in range(disponiveis.size()):
		var bloco_teste = disponiveis[i]
		var proximo_indice = coletados.size()
		
		# Corta caminhos óbvios que dariam erro (ex: testar colocar sinal onde é número)
		var is_numero = bloco_teste.is_valid_int()
		if proximo_indice % 2 == 0 and not is_numero: continue
		if proximo_indice % 2 != 0 and is_numero: continue
		
		# Cria uma linha do tempo alternativa e testa
		var nova_coletados = coletados.duplicate()
		nova_coletados.append(bloco_teste)
		
		var nova_disponiveis = disponiveis.duplicate()
		nova_disponiveis.remove_at(i)
		
		# Recursão: Se alguma destas linhas do tempo der certo, retorna verdadeiro
		if tem_solucao_futura(nova_coletados, nova_disponiveis):
			return true
			
	return false

func avaliar_expressao(arr: Array) -> float:
	var conta = ""
	for item in arr:
		if item == "x": conta += "*"
		else: conta += item
		
	var expressao = Expression.new()
	if expressao.parse(conta) == OK:
		var res = expressao.execute()
		if not expressao.has_execute_failed():
			return float(res)
	return -999999.0

func atualizar_hud() -> void:
	if not texto_hud: return
	
	var painel = ""
	for i in range(quantidade_necessaria):
		if i < blocos_coletados.size():
			painel += blocos_coletados[i] + " "
		else:
			if i % 2 == 0: painel += "_ " # Espaço de Número
			else: painel += "? " # Espaço de Sinal
				
	painel += "= " + str(resultado_esperado)
	texto_hud.text = painel

func animar_bloco_para_hud(valor: String, pos_inicial: Vector2) -> void:
	if not texto_hud: return
	
	# Cria uma cópia falsa do bloco só para fazer a animação
	var lbl_voando = Label.new()
	lbl_voando.text = valor
	lbl_voando.add_theme_font_size_override("font_size", 30)
	
	# Converte a posição do mapa para a posição do ecrã
	var pos_tela = get_viewport().canvas_transform * pos_inicial
	lbl_voando.position = pos_tela
	
	texto_hud.get_parent().add_child(lbl_voando)
	
	# Magia do Tween (Faz voar até à interface de forma suave)
	var tween = create_tween()
	var destino = texto_hud.position + Vector2(texto_hud.size.x / 2, 0)
	tween.tween_property(lbl_voando, "position", destino, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Quando o voo terminar: atualiza a HUD real e apaga a cópia voadora
	tween.tween_callback(atualizar_hud)
	tween.tween_callback(lbl_voando.queue_free)

func matar_jogador(jogador: CharacterBody2D) -> void:
	# 1. Congela o jogador
	jogador.set_physics_process(false)
	
	# 2. Desliga a colisão para ele cair pelo chão afora
	if jogador.has_node("CollisionShape2D"):
		jogador.get_node("CollisionShape2D").set_deferred("disabled", true)
		
	# 3. Animação de Morte Épica (Pulo + Giro + Queda)
	var tween = create_tween()
	var pos = jogador.position
	
	# PARTE A: Dá um pulinho para cima E começa a girar (em paralelo)
	tween.tween_property(jogador, "position", pos + Vector2(0, -80), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(jogador, "rotation_degrees", 360.0, 0.3)
	
	# PARTE B: Cai para o infinito E gira muito mais rápido (em cadeia, após o pulo)
	tween.chain().tween_property(jogador, "position", pos + Vector2(0, 800), 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(jogador, "rotation_degrees", 360.0 * 5, 1.0)
	
	# PARTE C: Quando a queda termina, reinicia a fase
	tween.chain().tween_callback(get_tree().reload_current_scene)

func limpar_blocos_restantes() -> void:
	# Pega todos os blocos que sobraram no mapa
	var blocos_sobrando = get_tree().get_nodes_in_group("blocos_fase")
	
	for bloco in blocos_sobrando:
		if is_instance_valid(bloco):
			# 1. Desliga a colisão imediatamente para garantir que a galinha não toca
			if bloco.has_node("CollisionShape2D"):
				bloco.get_node("CollisionShape2D").set_deferred("disabled", true)
			
			# 2. Efeito de Dissolver (Some e Encolhe ao mesmo tempo)
			var tween = create_tween()
			tween.parallel().tween_property(bloco, "modulate:a", 0.0, 0.4) # Fica transparente
			tween.parallel().tween_property(bloco, "scale", Vector2.ZERO, 0.4) # Encolhe para 0
			tween.chain().tween_callback(bloco.queue_free) # Apaga da memória no fim
