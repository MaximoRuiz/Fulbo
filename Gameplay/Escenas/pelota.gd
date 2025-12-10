extends CharacterBody2D

var speed_decay := 0.90 # fricción por frame
var fuerza_max := 900   # fuerza máxima permitida

func _ready() -> void:
	# Agregar al grupo "pelota"
	add_to_group("pelota")

func _physics_process(delta: float) -> void:
	# Aplicar fricción suave
	velocity *= speed_decay
	move_and_slide()

func empujar(dir: Vector2, fuerza: float) -> void:
	fuerza = min(fuerza, fuerza_max)
	velocity = dir.normalized() * fuerza
