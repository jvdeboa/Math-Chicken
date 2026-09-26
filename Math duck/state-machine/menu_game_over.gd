extends CanvasLayer

const MENU_PRINCIPAL = "res://menu_principal.tscn" 
const PRIMEIRA_FASE = "res://Scenes/Fases/fase_1.tscn" # Adicionamos o caminho da fase 1

func _on_botao_reiniciar_pressed() -> void:
	get_tree().paused = false # Tira o jogo da pausa
	get_tree().change_scene_to_file(PRIMEIRA_FASE) # Volta direto para o início do jogo!

func _on_botao_menu_pressed() -> void:
	get_tree().paused = false # Tira o jogo da pausa
	get_tree().change_scene_to_file(MENU_PRINCIPAL) # Volta para o menu inicial
