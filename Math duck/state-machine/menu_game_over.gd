extends CanvasLayer

const MENU_PRINCIPAL = "res://menu_principal.tscn" 
const PRIMEIRA_FASE = "res://Scenes/Fases/fase_1.tscn"



func _on_botao_reiniciar_pressed() -> void:
	get_tree().paused = false # Tira o jogo da pausa
	
	Mudarpont.pontuacao = 1 # Zera a pontuação global!
	
	get_tree().change_scene_to_file(PRIMEIRA_FASE)

func _on_botao_menu_pressed() -> void:
	get_tree().paused = false 
	
	Mudarpont.pontuacao = 0 
	
	get_tree().change_scene_to_file(MENU_PRINCIPAL)
