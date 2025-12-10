extends CharacterBody2D

var speed := 160
var player
var pelota
var detection_distance := 300

func _ready():
	var parent = get_parent()
	player = parent.get_node("Player")
	pelota = parent.get_node("Pelota")

func _physics_process(delta):
	if player == null:
		return

	var to_player = player.global_position - global_position
	var distance = to_player.length()

	var sees_player = distance < detection_distance

	if sees_player:
		var predicted_pos = player.global_position + player.velocity * 0.3
		mover_toward(predicted_pos)
	else:
		velocity = Vector2.ZERO
		move_and_slide()

func mover_toward(pos: Vector2):
	var dir = (pos - global_position).normalized()
	velocity = dir * speed
	move_and_slide()




func _on_hitbox_pierna_area_entered(area: Area2D) -> void:
	if area.is_in_group("pelota"):
		var pelota = area.get_parent()
		var dir = pelota.global_position - global_position
		pelota.empujar(dir, 800)
