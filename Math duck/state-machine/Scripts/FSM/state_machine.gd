class_name StateMachine extends Node

@export var initial_state: State

var active_state: State:
	set(new_value):
		active_state = new_value
		if active_state:
			print("Estado atual: ", active_state.name)

func _ready() -> void:
	for child_state in get_children():
		if child_state is State:
			child_state.switch_state.connect(change_state)
		
	if initial_state:
		change_state(initial_state)

func _process(delta: float) -> void:
	if active_state:
		active_state.update(delta)

# ADICIONADO AQUI: Sem isso, o physics_update dos seus estados NUNCA é executado!
func _physics_process(delta: float) -> void:
	if active_state:
		active_state.physics_update(delta)
		
func change_state(new_state: State) -> void:
	# Impede trocar se o novo estado for igual ou nulo
	if new_state == active_state or new_state == null:
		return 
		
	if active_state:
		active_state.exit_state()
		
	active_state = new_state
	
	if active_state:
		active_state.enter_state()
