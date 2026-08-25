extends CharacterBody2D
@export_group("Player Configuration")
@export var SPEED: float = 0.0
@export var JUMP_VELOCITY: float = -400.0
@export_group("Dash Configuration")
@export var dash_force: float = 300.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var dash_timer:float = 0.0
var can_dash: bool = true
