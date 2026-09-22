extends Area2D

@export var simbolo_manual: String = ""
var valor_do_bloco: String = ""

@onready var label: Label = $Label

func _ready() -> void:
	if simbolo_manual == "":
		valor_do_bloco = str(randi_range(0, 9))
	else:
		valor_do_bloco = simbolo_manual
	
	label.text = valor_do_bloco
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# Grita para o Gerenciador: o valor, a posição onde estava, e quem o apanhou!
		get_tree().call_group("gerenciador", "registrar_coleta", valor_do_bloco, global_position, body)
		queue_free()
