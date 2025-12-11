extends CharacterBody2D

var speed_decay := 0.82   # fricción por frame (más chico → se frena antes)
var fuerza_max := 450.0   # fuerza máxima permitida (no se va a la mierda)


func _ready() -> void:
	# Agregar al grupo "pelota"
	add_to_group("pelota")


func _physics_process(delta: float) -> void:
	# Aplicar fricción suave
	velocity *= speed_decay

	# Si ya casi no se mueve, frenarla del todo
	if velocity.length() < 5.0:
		velocity = Vector2.ZERO

	move_and_slide()


func empujar(dir: Vector2, fuerza: float) -> void:
	fuerza = min(fuerza, fuerza_max)
	velocity = dir.normalized() * fuerza
