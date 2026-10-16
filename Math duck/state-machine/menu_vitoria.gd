extends CanvasLayer # (ou extends Control, dependendo do tipo do seu nó raiz)

const MENU_PRINCIPAL = "res://menu_principal.tscn" 

func _ready() -> void:
	# 1. Puxa o foco direto para o botão "menu", para o joystick já selecioná-lo
	$VBoxContainer/menu.grab_focus()
	
	# 2. Puxa a pontuação final do seu AutoLoad e escreve na tela
	$VBoxContainer/TextoPontos.text = "Pontuação Final: " + str(Mudarpont.pontuacao)

# Lembre-se de conectar o sinal "pressed()" do seu botão "menu" a esta função!
func _on_menu_pressed() -> void:
	get_tree().paused = false # Tira do pause
	
	Mudarpont.pontuacao = 0 # Zera a pontuação para quando o jogador quiser jogar de novo
	
	get_tree().change_scene_to_file(MENU_PRINCIPAL) # Volta pra tela inicial
