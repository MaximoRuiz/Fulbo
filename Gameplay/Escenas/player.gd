extends CharacterBody2D

var speed: float = 220.0

# Referencia a la pelota
var pelota: CharacterBody2D = null

# --------------------
# SISTEMA DE RUTA
# --------------------
var path: Array[Vector2] = []   # puntos globales de la línea
var target_index: int = 0       # índice actual en el path
var siguiendo_ruta: bool = false


# “Rango” de movimiento alrededor de la línea
const CHASE_RADIUS: float = 200.0   # hasta qué distancia persigue la pelota
const REACH_POINT_DIST: float = 10.0



func _ready() -> void:
	# Buscar la pelota en toda la escena (por si cambia la jerarquía)
	var root: Node = get_tree().current_scene
	var found := root.find_child("Pelota", true, false)
	if found is CharacterBody2D:
		pelota = found
	else:
		print("WARN: No encontré nodo 'Pelota' en la escena.")


func _physics_process(delta: float) -> void:
	if siguiendo_ruta:
		seguir_ruta(delta)
	else:
		velocity = Vector2.ZERO

	# Rotar el jugador según hacia dónde se está moviendo
	if velocity.length() > 0.1:
		rotation = velocity.angle()


# ============================================================
#   EMPUJAR LA PELOTA SEGÚN LA DIRECCIÓN DE LA LÍNEA
# ============================================================

func _on_hitbox_pierna_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pelota"):
		return

	var bola := area.get_parent() as CharacterBody2D
	if bola == null:
		return

	var dir: Vector2
	var fuerza: float

	# 1) Si estamos siguiendo una ruta y hay al menos 2 puntos,
	#    usamos el segmento path[target_index] -> path[target_index+1]
	#    como “derivada” (tangente) de la línea.
	if siguiendo_ruta and path.size() > 1:
		var idx: int = clampi(target_index, 0, path.size() - 2)
		var p0: Vector2 = path[idx]
		var p1: Vector2 = path[idx + 1]

		var tangente: Vector2 = p1 - p0
		if tangente.length() > 0.1:
			dir = tangente.normalized()
		else:
			dir = (p1 - bola.global_position).normalized()

		# Toque corto, un poco por delante del jugador
		fuerza = 330.0

	# 2) Si NO hay ruta → usar la dirección actual de movimiento del jugador
	elif velocity.length() > 0.1:
		dir = velocity.normalized()
		var fuerza_calc: float = velocity.length()
		fuerza = clampf(fuerza_calc, 260.0, 420.0)

	# 3) Jugador casi quieto → empujón suave hacia la pelota
	else:
		dir = (bola.global_position - global_position).normalized()
		fuerza = 250.0

	bola.empujar(dir, fuerza)


# ============================================================
#               SISTEMA DE SEGUIR RUTA DIBUJADA
#      (con desvío para buscar la pelota)
# ============================================================

func set_path(new_path: Array[Vector2]) -> void:
	path = new_path
	target_index = 0
	siguiendo_ruta = path.size() > 0


func seguir_ruta(delta: float) -> void:
	if path.is_empty():
		siguiendo_ruta = false
		velocity = Vector2.ZERO
		return

	if target_index >= path.size():
		siguiendo_ruta = false
		velocity = Vector2.ZERO

		# BORRAR LA LÍNEA CUANDO TERMINA
		var parent := get_parent()
		if parent and parent.has_node("Linea"):
			var linea = parent.get_node("Linea")
			if linea is Line2D:
				linea.points = []
		return

	# Punto “ideal” sobre la línea
	var base_objetivo: Vector2 = path[target_index]
	# Objetivo real al que nos vamos a mover (puede desviarse hacia la pelota)
	var objetivo: Vector2 = base_objetivo

	if pelota:
		var dist_jugador_pelota: float = (pelota.global_position - global_position).length()

		# Si la pelota está dentro del radio → perseguirla en vez de ir directo al punto
		if dist_jugador_pelota < CHASE_RADIUS:
			objetivo = pelota.global_position

	# Avanzar al siguiente punto del path cuando nos acercamos lo suficiente
	var dist_a_base: float = (base_objetivo - global_position).length()
	if dist_a_base < REACH_POINT_DIST:
		target_index += 1
		return

	# Mover al jugador hacia el objetivo (línea o pelota)
	var dir: Vector2 = objetivo - global_position
	if dir.length() > 0.1:
		velocity = dir.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
