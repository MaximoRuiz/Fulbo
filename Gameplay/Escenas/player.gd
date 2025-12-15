extends CharacterBody2D

var speed := 220

# --------------------
# SISTEMA DE PELOTA
# --------------------
var tiene_pelota := false
var pelota: CharacterBody2D




func _physics_process(delta):
	# Si está siguiendo una ruta → mover por ruta
	if siguiendo_ruta:
		seguir_ruta(delta)
	else:
		velocity = Vector2.ZERO

	# --- si tiene la pelota, pegarla al PuntoPelota ---
	if tiene_pelota and pelota:
		var destino = $PuntoPelota.global_position
		pelota.global_position = destino

		if Input.is_action_just_pressed("ui_accept"):
			patear_pelota()

	# --- ROTACIÓN DEL JUGADOR ---
	if velocity.length() > 0:
		rotation = velocity.angle()

	# --- ROTAR TAMBIÉN LA PELOTA ---
	if tiene_pelota and pelota:
		pelota.rotation = rotation

func _on_hitbox_pierna_area_entered(area: Area2D) -> void:
	if area.is_in_group("pelota"):
		tomar_pelota(area.get_parent())


func tomar_pelota(p: CharacterBody2D) -> void:
	tiene_pelota = true
	pelota = p
	
	# desactivar colisiones para que no empuje al jugador
	pelota.set_collision_layer(0)
	pelota.set_collision_mask(0)

	pelota.velocity = Vector2.ZERO
	pelota.global_position = $PuntoPelota.global_position
	print("Pelota tomada")


func patear_pelota() -> void:
	if not tiene_pelota:
		return

	var dir := (pelota.global_position - global_position).normalized()
	pelota.empujar(dir, 900)

	# volver a activar colisiones
	pelota.set_collision_layer(1)
	pelota.set_collision_mask(1)

	tiene_pelota = false
	print("Pelota pateada")



# ============================================================
#               SISTEMA DE SEGUIR RUTA DIBUJADA
# ============================================================

var path := []             # lista de puntos globales
var target_index := 0      # a qué punto del camino voy
var siguiendo_ruta := false


func set_path(new_path):
	# Recibe una lista de Vector2 (globales)
	path = new_path
	target_index = 0
	siguiendo_ruta = true


func seguir_ruta(delta):
	if target_index >= path.size():
		siguiendo_ruta = false
		velocity = Vector2.ZERO
		
		# BORRAR LA LÍNEA CUANDO TERMINA
		get_parent().get_node("Linea").points = []
		return


	var objetivo = path[target_index]
	var dir = objetivo - global_position

	# Si llega cerca del punto, pasar al próximo
	if dir.length() < 10:
		target_index += 1
		return

	# Mover hacia el punto
	velocity = dir.normalized() * speed
	move_and_slide()
