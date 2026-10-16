extends Node

# Cria um sinal que vai avisar o Label quando a pontuação mudar
signal pontuacao_mudou(novo_valor)

var pontuacao: int = 1

func adicionar_ponto(valor: int = 1) -> void:
	pontuacao += valor
	# Dispara o aviso para o Label atualizar
	pontuacao_mudou.emit(pontuacao)
