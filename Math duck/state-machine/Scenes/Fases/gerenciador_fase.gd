extends Node

@export var cena_bloco_numeral: PackedScene
@export var cena_bloco_sinal: PackedScene
@export var grupo_spawn_points: Node2D
@export var nivel_dificuldade: int = 1

# --- NOVAS VARIÁVEIS PARA CONTROLAR O JOGO ---
var resultado_esperado: int = 0
var blocos_coletados: Array[String] = []
var quantidade_necessaria: int = 3

func _ready() -> void:
	add_to_group("gerenciador") # Coloca a etiqueta de gerenciador
	gerar_nova_equacao()

func gerar_nova_equacao() -> void:
	var quantidade_numeros: int = 2
	var operacoes_permitidas: Array = []
	var quantidade_iscos: int = 0
	
	match nivel_dificuldade:
		1: 
			quantidade_numeros = 2
			operacoes_permitidas = ["+"]
			quantidade_iscos = 1 
			quantidade_necessaria = 3 # Ex: 2, +, 3
		2: 
			quantidade_numeros = 2
			operacoes_permitidas = ["+", "-", "x"]
			quantidade_iscos = 2 
			quantidade_necessaria = 3
		3: 
			quantidade_numeros = 3
			operacoes_permitidas = ["+", "-", "x"]
			quantidade_iscos = 2 
			quantidade_necessaria = 5 # Ex: 2, +, 3, x, 4
			
	var numeros_certos: Array = []
	for i in range(quantidade_numeros):
		numeros_certos.append(randi_range(1, 9))
		
	var operadores_certos: Array = []
	for i in range(quantidade_numeros - 1):
		operadores_certos.append(operacoes_permitidas.pick_random())
		
	resultado_esperado = calcular_resultado(numeros_certos, operadores_certos)
	
	var texto_objetivo = "Objetivo: Formar "
	for i in range(numeros_certos.size()):
		texto_objetivo += str(numeros_certos[i]) + " "
		if i < operadores_certos.size():
			texto_objetivo += operadores_certos[i] + " "
	texto_objetivo += "= " + str(resultado_esperado)
	print(texto_objetivo)
	
	var blocos_para_criar: Array[String] = []
	for n in numeros_certos:
		blocos_para_criar.append(str(n))
	for op in operadores_certos:
		blocos_para_criar.append(op)
		
	for i in range(quantidade_iscos):
		blocos_para_criar.append(str(randi_range(0, 9)))
		
	if nivel_dificuldade >= 2:
		blocos_para_criar.append(["+", "-", "x"].pick_random())
		
	blocos_para_criar.shuffle()
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
		if i >= pontos_disponiveis.size():
			break
			
		var valor_atual = blocos[i]
		var novo_bloco: Area2D
		
		if valor_atual in ["+", "-", "x"]:
			novo_bloco = cena_bloco_sinal.instantiate()
		else:
			novo_bloco = cena_bloco_numeral.instantiate()
			
		novo_bloco.simbolo_manual = valor_atual 
		novo_bloco.global_position = pontos_disponiveis[i].global_position
		get_parent().add_child.call_deferred(novo_bloco)

# --- NOVO SISTEMA DE VERIFICAÇÃO ---
func registrar_coleta(valor_coletado: String) -> void:
	blocos_coletados.append(valor_coletado)
	print("Você coletou: ", blocos_coletados)
	
	# Quando o jogador pega a quantidade certa de blocos, o jogo confere a resposta
	if blocos_coletados.size() == quantidade_necessaria:
		validar_equacao()

func validar_equacao() -> void:
	var expressao_str = ""
	for item in blocos_coletados:
		if item == "x":
			expressao_str += "*" # O motor da Godot usa '*' para multiplicar
		else:
			expressao_str += item
			
	# Usa o avaliador matemático nativo do Godot
	var expressao = Expression.new()
	var erro = expressao.parse(expressao_str)
	
	if erro == OK:
		var resultado_jogador = expressao.execute()
		
		# Confere se a conta deu certo E se o valor bate com o esperado
		if not expressao.has_execute_failed() and int(resultado_jogador) == resultado_esperado:
			print("o portal foi destrancado")
			get_tree().call_group("portal", "activate")
			return
			
	# Se deu erro de sintaxe (ex: pegou dois sinais seguidos) ou se o resultado deu errado:
	print("ERROU! A fase será reiniciada...")
	await get_tree().create_timer(1.0).timeout # Espera 1 segundo
	get_tree().reload_current_scene() # Reinicia a fase para tentar de novo
