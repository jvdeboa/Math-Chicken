extends Label

func _ready() -> void:
	# 1. Quando a fase começar, ele já puxa a pontuação correta
	text = "Pontos: " + str(Mudarpont.pontuacao)
	
	# 2. Conecta esse Label direto ao sinal do Global
	Mudarpont.pontuacao_mudou.connect(_ao_mudar_pontuacao)

# Essa função roda automaticamente sempre que o Portal der um ponto
func _ao_mudar_pontuacao(novo_valor: int) -> void:
	text = "Pontos: " + str(novo_valor)
