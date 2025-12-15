extends Area2D

var dragging := true

func set_dragging(v: bool) -> void:
	dragging = v

func _process(delta: float) -> void:
	if not dragging:
		return

	var mouse_pos := get_global_mouse_position()
	var linea := get_parent().get_node("Linea") as Line2D

	if linea and linea.points.size() >= 2:
		global_position = _closest_point_on_line(linea, mouse_pos)
	else:
		global_position = mouse_pos


func _closest_point_on_line(linea: Line2D, point: Vector2) -> Vector2:
	var closest := linea.to_global(linea.points[0])
	var min_dist_sq := closest.distance_squared_to(point)

	for i in range(linea.points.size() - 1):
		var a := linea.to_global(linea.points[i])
		var b := linea.to_global(linea.points[i + 1])

		var ab := b - a
		var ab_len_sq := ab.length_squared()
		var t := 0.0
		if ab_len_sq > 0.0001:
			t = clamp(((point - a).dot(ab)) / ab_len_sq, 0.0, 1.0)

		var proj := a + ab * t
		var dist_sq := proj.distance_squared_to(point)

		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			closest = proj

	return closest
