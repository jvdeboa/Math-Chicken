extends Control

const PRIMEIRA_FASE = "res://Scenes/Fases/fase_1.tscn"

func _on_botao_jogar_pressed() -> void:
	get_tree().change_scene_to_file(PRIMEIRA_FASE)

func _on_botao_sair_pressed() -> void:
	get_tree().quit()
