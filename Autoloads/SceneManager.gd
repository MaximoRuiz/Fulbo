extends Node

const LEVEL_H: int = 960
const LEVEL_W: int = 540

signal load_start(loading_screen)
signal scene_added(loaded_scene: Node, loading_screen)
signal load_complete(loaded_scene: Node)

signal _content_finished_loading(content)
signal _content_invalid(content_path: String)
signal _content_failed_to_load(content_path: String)

@onready var _loading_screen_scene: PackedScene = preload("res://Menus/loading_canvass.tscn")

var _loading_screen: Node = null
var _transition: String = ""
var _zelda_transition_direction: Vector2 = Vector2.ZERO
var _content_path: String = ""
var _load_progress_timer: Timer = null
var _load_scene_into: Node = null
var _scene_to_unload: Node = null
var _loading_in_progress: bool = false

func _ready() -> void:
	_content_invalid.connect(_on_content_invalid)
	_content_failed_to_load.connect(_on_content_failed_to_load)
	_content_finished_loading.connect(_on_content_finished_loading)

func _add_loading_screen(transition_type: String = "fade_to_black") -> void:
	_transition = "no_to_transition" if transition_type == "no_transition" else transition_type
	_loading_screen = _loading_screen_scene.instantiate()
	get_tree().root.add_child(_loading_screen)
	if _loading_screen.has_method("start_transition"):
		_loading_screen.start_transition(_transition)

func _resolve_scene_to_unload(scene_to_unload: Node) -> Node:
	var current := get_tree().current_scene
	if current == null:
		return scene_to_unload

	# Si no te pasan nada -> borro la escena actual completa
	if scene_to_unload == null:
		return current

	# Si te pasan un nodo interno (ej: self) -> borro la escena actual completa
	if scene_to_unload == current or current.is_ancestor_of(scene_to_unload):
		return current

	# Si te pasan realmente la escena completa -> uso eso
	return scene_to_unload

func swap_scenes(scene_to_load: String, load_into: Node = null, scene_to_unload: Node = null, transition_type: String = "fade_to_black") -> void:
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return

	_loading_in_progress = true
	if load_into == null:
		load_into = get_tree().root

	_load_scene_into = load_into
	_scene_to_unload = _resolve_scene_to_unload(scene_to_unload)

	_add_loading_screen(transition_type)
	_load_content(scene_to_load)

func swap_scenes_zelda(scene_to_load: String, load_into: Node, scene_to_unload: Node, move_dir: Vector2) -> void:
	if _loading_in_progress:
		push_warning("SceneManager is already loading something")
		return

	_loading_in_progress = true
	_transition = "zelda"
	_load_scene_into = load_into
	_scene_to_unload = _resolve_scene_to_unload(scene_to_unload)
	_zelda_transition_direction = move_dir

	_load_content(scene_to_load)

func _load_content(content_path: String) -> void:
	load_start.emit(_loading_screen)

	# zelda no usa loading screen
	if _transition != "zelda" and _loading_screen != null and _loading_screen.has_signal("transition_in_complete"):
		await _loading_screen.transition_in_complete

	_content_path = content_path

	if not ResourceLoader.exists(content_path):
		_content_invalid.emit(content_path)
		_loading_in_progress = false
		return

	var err := ResourceLoader.load_threaded_request(content_path)
	if err != OK:
		_content_failed_to_load.emit(content_path)
		_loading_in_progress = false
		return

	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.one_shot = false
	_load_progress_timer.timeout.connect(_monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

func _monitor_load_status() -> void:
	var prog: Array = []
	var status := ResourceLoader.load_threaded_get_status(_content_path, prog)

	match status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			_content_invalid.emit(_content_path)
			_cleanup_timer()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _loading_screen != null and _loading_screen.has_method("update_bar") and prog.size() > 0:
				_loading_screen.update_bar(prog[0] * 100.0)
		ResourceLoader.THREAD_LOAD_FAILED:
			_content_failed_to_load.emit(_content_path)
			_cleanup_timer()
		ResourceLoader.THREAD_LOAD_LOADED:
			_cleanup_timer()
			var res := ResourceLoader.load_threaded_get(_content_path)
			if res == null:
				_content_failed_to_load.emit(_content_path)
				_loading_in_progress = false
				return
			_content_finished_loading.emit(res.instantiate())

func _cleanup_timer() -> void:
	if _load_progress_timer != null:
		_load_progress_timer.stop()
		_load_progress_timer.queue_free()
		_load_progress_timer = null

func _on_content_failed_to_load(path: String) -> void:
	printerr("error: Failed to load resource: '%s'" % [path])

func _on_content_invalid(path: String) -> void:
	printerr("error: Cannot load resource: '%s'" % [path])

func _on_content_finished_loading(incoming_scene: Node) -> void:
	var outgoing_scene := _scene_to_unload

	# pasar data si ambos implementan métodos
	if outgoing_scene != null and is_instance_valid(outgoing_scene):
		if outgoing_scene.has_method("get_data") and incoming_scene.has_method("receive_data"):
			incoming_scene.receive_data(outgoing_scene.get_data())

	# agregar nueva escena
	_load_scene_into.add_child(incoming_scene)

	# ✅ clave para que siempre “la escena actual” sea la nueva cuando cargás al root
	if _load_scene_into == get_tree().root:
		get_tree().current_scene = incoming_scene

	scene_added.emit(incoming_scene, _loading_screen)

	# transición zelda: mover escenas
	if _transition == "zelda" and outgoing_scene != null and is_instance_valid(outgoing_scene):
		incoming_scene.position = Vector2(_zelda_transition_direction.x * LEVEL_W, _zelda_transition_direction.y * LEVEL_H)

		var tween_in := get_tree().create_tween()
		tween_in.tween_property(incoming_scene, "position", Vector2.ZERO, 1).set_trans(Tween.TRANS_SINE)

		var tween_out := get_tree().create_tween()
		var off := Vector2(-_zelda_transition_direction.x * LEVEL_W, -_zelda_transition_direction.y * LEVEL_H)
		tween_out.tween_property(outgoing_scene, "position", off, 1).set_trans(Tween.TRANS_SINE)

		await tween_in.finished

	# borrar escena vieja (si existe)
	if outgoing_scene != null and is_instance_valid(outgoing_scene) and outgoing_scene != get_tree().root:
		outgoing_scene.queue_free()

	# init antes de devolver control
	if incoming_scene.has_method("init_scene"):
		incoming_scene.init_scene()

	# cerrar transición normal
	if _loading_screen != null and _loading_screen.has_method("finish_transition"):
		_loading_screen.finish_transition()
		if _loading_screen.has_node("AnimationPlayer"):
			var ap: AnimationPlayer = _loading_screen.get_node("AnimationPlayer")
			await ap.animation_finished

	# start scene (devolver control, etc.)
	if incoming_scene.has_method("start_scene"):
		incoming_scene.start_scene()

	_loading_in_progress = false
	load_complete.emit(incoming_scene)
