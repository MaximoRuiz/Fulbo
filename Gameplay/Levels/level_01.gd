extends Node2D

var tiempo_max := 10.0
var tiempo_actual := 10.0

@onready var barra = $BarraTiempo
@onready var timer = $TiempoPartida

func _ready():
	reiniciar_tiempo()

func _physics_process(delta):
	tiempo_actual -= delta
	barra.value = tiempo_actual

	if tiempo_actual <= 0:
		await_tiempo_reinicio()

func await_tiempo_reinicio():
	# Tiempo antes de reiniciar (0.8 segundos por ejemplo)
	await get_tree().create_timer(0.8).timeout
	
	reiniciar_tiempo()

func reiniciar_tiempo():
	tiempo_actual = tiempo_max
	barra.value = tiempo_max
	timer.start()
	print("⏱️ Timer reiniciado")

func _on_barra_tiempo_value_changed(value: float) -> void:
	# Verde (seguro)
	if value > 6:
		$BarraTiempo.modulate = Color(0.2, 1.0, 0.2)   # verde
	
	# Amarillo (peligro)
	elif value > 3:
		$BarraTiempo.modulate = Color(1.0, 1.0, 0.2)   # amarillo
	
	# Rojo (crítico)
	else:
		$BarraTiempo.modulate = Color(1.0, 0.2, 0.2)   # rojo
