extends Area2D


@export_file("*.tscn") var target_scene: String


@export var ativo: bool = false:
	set(value):
		ativo = value
		_update_portal_state()


@onready var cadeado: Sprite2D = $cadeado

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_portal_state()

func _update_portal_state() -> void:
	if not is_inside_tree():
		await ready
		

	$CollisionShape2D.set_deferred("disabled", not ativo)
	
	
	if cadeado:
		cadeado.visible = not ativo

func _on_body_entered(body: Node2D) -> void:
	
	if ativo and body is CharacterBody2D:
		if target_scene != "":
			get_tree().change_scene_to_file(target_scene)
		else:
			push_warning("Nenhuma cena de destino configurada no Portal")


func activate() -> void:
	ativo = true


func deactivate() -> void:
	ativo = false
