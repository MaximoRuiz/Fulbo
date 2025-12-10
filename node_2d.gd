extends Node2D

var drawing := false
@onready var linea := get_node("Linea")
@onready var player := get_node("Player")


func _input(event):
	# --- INICIO DE DIBUJO ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed
		
		if event.pressed:
			# Cuando vuelvo a presionar, sigo agregando puntos (NO se borra la línea)
			var local_pos = linea.to_local(event.position)
			linea.add_point(local_pos)

	# --- MIENTRAS ARRASTRO ---
	if event is InputEventMouseMotion and drawing:
		var local_pos = linea.to_local(event.position)

		# Evitar puntos repetidos muy juntos
		if linea.points.size() == 0 or linea.points[-1].distance_to(local_pos) > 5:
			linea.add_point(local_pos)


func _process(delta):
	# BOTÓN PARA ENVIAR EL RECORRIDO
	if Input.is_action_just_pressed("ui_accept"):  # cambialo al botón que quieras
		enviar_ruta_al_jugador()


func enviar_ruta_al_jugador():
	if linea.points.size() < 2:
		return

	# Convertir puntos locales de Line2D a globales
	var path_global := []
	for p in linea.points:
		path_global.append(linea.to_global(p))

	player.set_path(path_global)
