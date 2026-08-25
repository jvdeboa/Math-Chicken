extends Sprite2D

func _ready() -> void:
	# Anima a transparência (alpha) do rastro de 0.5 até 0 em 0.25 segundos
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	
	# Quando o efeito terminar, remove a cópia da memória
	tween.tween_callback(queue_free)
