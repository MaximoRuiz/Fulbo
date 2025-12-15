extends Node2D

@export var ability_token_scene: PackedScene

var drawing: bool = false
var placing_token: bool = false
var current_token: Node = null

@onready var linea: Line2D = get_node("Linea")
@onready var player: CharacterBody2D = get_node("Player")


func _ready() -> void:
	# Para borrar tokens cuando el jugador termina la ruta
	# (esto requiere que Player.gd tenga: signal ruta_terminada y emit_signal al terminar)
	if player.has_signal("ruta_terminada"):
		player.ruta_terminada.connect(_on_player_ruta_terminada)


func _unhandled_input(event: InputEvent) -> void:
	# 1) SI ESTAMOS COLOCANDO UN TOKEN: EL CLICK IZQUIERDO SOLO "CONFIRMA" Y NO DIBUJA
	if placing_token:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if current_token and current_token.has_method("set_dragging"):
				current_token.set_dragging(false)

			placing_token = false
			current_token = null
			drawing = false
			return

		# Mientras colocamos token, ignoramos todo el input de dibujo
		return

	# 2) DIBUJO NORMAL DE LA LÍNEA
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mb := event as InputEventMouseButton
		drawing = mb.pressed

		if mb.pressed:
			var local_pos: Vector2 = linea.to_local(mb.position)
			linea.add_point(local_pos)

	if event is InputEventMouseMotion and drawing:
		var mm := event as InputEventMouseMotion
		var local_pos2: Vector2 = linea.to_local(mm.position)

		# Evitar puntos repetidos muy juntos
		if linea.points.size() == 0 or linea.points[-1].distance_to(local_pos2) > 5.0:
			linea.add_point(local_pos2)


func _process(delta: float) -> void:
	# Espacio/Enter (ui_accept) sigue funcionando si querés
	if Input.is_action_just_pressed("ui_accept"):
		enviar_ruta_al_jugador()


func enviar_ruta_al_jugador() -> void:
	if linea.points.size() < 2:
		return

	var path_global: Array[Vector2] = []
	for p in linea.points:
		path_global.append(linea.to_global(p))

	player.set_path(path_global)


# ------------ TOKENS / HABILIDADES ------------

func crear_ability_token(color: Color) -> void:
	if ability_token_scene == null:
		return

	var token := ability_token_scene.instantiate()
	add_child(token)

	# Spawn cerca del mouse (en coordenadas globales del mundo)
	token.global_position = get_global_mouse_position()
	token.modulate = color

	# Entramos en modo "colocación"
	placing_token = true
	current_token = token
	drawing = false


func _on_red_button_pressed() -> void:
	crear_ability_token(Color.RED)


func _on_start_button_pressed() -> void:
	enviar_ruta_al_jugador()


func _on_player_ruta_terminada() -> void:
	# Borra todos los tokens al terminar la ruta
	get_tree().call_group("ability_tokens", "queue_free")
