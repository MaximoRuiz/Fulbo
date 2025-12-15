extends Node2D

var tiempo_max := 10.0
var tiempo_actual := 10.0
@onready var barra = $BarraTiempo
@onready var timer = $TiempoPartida
@onready var pelota = $Pelota  # ¿Existe $Pelota? Si no, ERROR en consola
var reiniciando : bool = false
var ya_gane = false
@onready var escena = preload("res://Gameplay/Levels/Level01.tscn")
func _ready():
	if not pelota:  # DEBUG: ¿Pelota existe?
		print("❌ ERROR: $Pelota NO EXISTE! Crea el nodo Pelota.")
		return
	print("✅ Pelota OK. Ancho pantalla: ", get_viewport_rect().size.x)
	print("🎯 Meta en X >= ", get_viewport_rect().size.x * 0.95)
	reiniciar_tiempo()

func _physics_process(delta):
	if reiniciando:
		return

	tiempo_actual -= delta
	barra.value = tiempo_actual
	
	# DEBUG ULTRA: Cada frame
	
	
	
	if tiempo_actual <= 0:
	
		reiniciando = true
		await_tiempo_reinicio()

func await_tiempo_reinicio():
	await get_tree().create_timer(0.8).timeout
	reiniciar_tiempo()
	reiniciando = false  # ← Esto evita FREEZE

func reiniciar_tiempo():
	tiempo_actual = tiempo_max
	barra.value = tiempo_max
	timer.start()
	print("⏱️ Timer REINICIADO")

		
		

func _on_barra_tiempo_value_changed(value: float) -> void:
	if value > 6: $BarraTiempo.modulate = Color(0.2, 1.0, 0.2)
	elif value > 3: $BarraTiempo.modulate = Color(1.0, 1.0, 0.2)
	else: $BarraTiempo.modulate = Color(1.0, 0.2, 0.2)


func _on_meta_body_entered(body):
	if body == pelota:
		print("GANASTE")
		SceneManager.swap_scenes(SceneRegistry.levels["segundo_nivel"],get_tree().root,self,"wipe_to_right")	
