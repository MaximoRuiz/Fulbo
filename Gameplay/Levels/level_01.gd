extends Node2D

var tiempo_max := 15.0
var tiempo_actual := 15.0

@onready var barra = $BarraTiempo
@onready var timer = $TiempoPartida
@onready var pelota = $Pelota

var cambiando_escena: bool = false

func _ready():
	reiniciar_tiempo()

func _physics_process(delta):
	if cambiando_escena:
		return

	tiempo_actual -= delta
	barra.value = tiempo_actual

	if tiempo_actual <= 0.0:
		cambiando_escena = true
		# Reemplazá la escena completa (Level01) por Lost
		call_deferred("_go_lost")

func _go_lost() -> void:
	SceneManager.swap_scenes(
		SceneRegistry.main_scenes["lost"],
		get_tree().root,
		get_tree().current_scene,
		"wipe_to_right"
	)

func reiniciar_tiempo():
	tiempo_actual = tiempo_max
	barra.max_value = tiempo_max
	barra.value = tiempo_actual
	timer.start()

func _on_barra_tiempo_value_changed(value: float) -> void:
	if value > 6:
		$BarraTiempo.modulate = Color(0.2, 1.0, 0.2)
	elif value > 3:
		$BarraTiempo.modulate = Color(1.0, 1.0, 0.2)
	else:
		$BarraTiempo.modulate = Color(1.0, 0.2, 0.2)

func _on_meta_body_entered(body):
	if body == pelota:
		print("GANASTE")
		SceneManager.swap_scenes(
			SceneRegistry.levels["segundo_nivel"],
			get_tree().root,
			get_tree().current_scene,
			"wipe_to_right"
		)
