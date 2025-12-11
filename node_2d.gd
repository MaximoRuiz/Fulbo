extends Node2D

var drawing := false

@onready var linea: Line2D = get_node("Linea")
@onready var player: CharacterBody2D = get_node("Player")


func _input(event: InputEvent) -> void:
	# --- INICIO DE DIBUJO ---
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		drawing = mb.pressed
		
		if mb.pressed:
			var local_pos: Vector2 = linea.to_local(mb.position)
			linea.add_point(local_pos)

	# --- MIENTRAS ARRASTRO ---
	if event is InputEventMouseMotion and drawing:
		var mm := event as InputEventMouseMotion
		var local_pos2: Vector2 = linea.to_local(mm.position)

		# Evitar puntos repetidos muy juntos
		if linea.points.size() == 0 or linea.points[-1].distance_to(local_pos2) > 5.0:
			linea.add_point(local_pos2)


func _process(delta: float) -> void:
	# BOTÓN PARA ENVIAR EL RECORRIDO
	if Input.is_action_just_pressed("ui_accept"):  # espacio por defecto
		enviar_ruta_al_jugador()


func enviar_ruta_al_jugador() -> void:
	if linea.points.size() < 2:
		return

	var path_global: Array[Vector2] = []
	for p in linea.points:
		path_global.append(linea.to_global(p))

	player.set_path(path_global)
