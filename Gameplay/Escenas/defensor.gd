extends CharacterBody2D

var speed := 160
var player
var pelota
var detection_distance := 500
var tiene_pelota := false

func _ready():
	var parent = get_parent()
	player = parent.get_node("Player")
	pelota = parent.get_node("Pelota")
	print(pelota)

func _physics_process(delta):
	if not pelota:
		return

	var to_pelota = pelota.global_position - global_position
	var distance = to_pelota.length()
	
	var sees_pelota = distance < detection_distance
	
	if sees_pelota == true and distance > 10:
		var predicted_pos = pelota.global_position + pelota.velocity * 0.3
		mover_toward(predicted_pos)
	elif sees_pelota == true:
		var predicted_pos = pelota.global_position 
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func mover_toward(pos: Vector2):
	var dir = (pos - global_position).normalized()
	velocity = dir * speed
	move_and_slide()




func _on_hitbox_pierna_area_entered(area: Area2D) -> void:
	if area.is_in_group("pelota"):
		var p = area.get_parent()  # pelota real
		var dir = (p.global_position - global_position).normalized()
		p.empujar(dir, 800)


func tomar_pelota(p: CharacterBody2D) -> void:
	tiene_pelota = true
	pelota = p
	
	# desactivar colisiones para que no empuje al jugador
	pelota.set_collision_layer(0)
	pelota.set_collision_mask(0)
	var dir = (pelota.global_position - global_position).normalized()
	pelota.empujar(dir, 900)
	pelota.velocity = Vector2.ZERO
	
	print("Pelota tomada")
	
func patear_pelota() -> void:
	if not tiene_pelota:
		return



	# volver a activar colisiones
	pelota.set_collision_layer(1)
	pelota.set_collision_mask(1)

	tiene_pelota = false
