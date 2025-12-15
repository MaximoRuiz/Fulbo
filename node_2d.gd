extends Node2D

@export var ability_token_scene: PackedScene

var placing_token := false
var current_token: Node = null
var drawing := false
var token_dragging := false
@onready var linea := get_node("Linea")
@onready var player := get_node("Player")


func _unhandled_input(event):
	# 1) Si estamos colocando un token, ESTE CLICK NO DIBUJA
	if placing_token:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# confirmar ubicación del token
			if current_token:
				current_token.set_dragging(false)
			placing_token = false
			current_token = null

			# cortar el dibujo por si venías arrastrando
			drawing = false
			return

		# mientras colocás token, ignorar todo lo demás del dibujo
		return

	# 2) DIBUJO NORMAL (tu código de siempre)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed

		if event.pressed:
			var local_pos = linea.to_local(event.position)
			linea.add_point(local_pos)

	if event is InputEventMouseMotion and drawing:
		var local_pos = linea.to_local(event.position)

		if linea.points.size() == 0 or linea.points[-1].distance_to(local_pos) > 5:
			linea.add_point(local_pos)



func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		enviar_ruta_al_jugador()


func enviar_ruta_al_jugador():
	if linea.points.size() < 2:
		return

	var path_global := []
	for p in linea.points:
		path_global.append(linea.to_global(p))

	player.set_path(path_global)


# ------------ TOKENS / HABILIDADES ------------

func _on_token_drag_state_changed(is_dragging: bool) -> void:
	token_dragging = is_dragging
	if token_dragging:
		drawing = false


func crear_ability_token(color: Color) -> void:
	if ability_token_scene == null:
		return

	var token := ability_token_scene.instantiate()
	add_child(token)

	token.global_position = get_viewport().get_mouse_position()
	token.modulate = color

	# activar modo "colocación"
	placing_token = true
	current_token = token

	# por las dudas cortamos el dibujo actual
	drawing = false



func _on_red_button_pressed() -> void:
	crear_ability_token(Color.RED)


func _on_start_button_pressed() -> void:
	enviar_ruta_al_jugador()
