extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_settings_pressed() -> void:
	Globals.open_settings_menu()

func _on_retry_pressed() -> void:
	# Reemplaza la escena actual (Lost) por Level01
	call_deferred("_go_retry")

func _go_retry() -> void:
	SceneManager.swap_scenes(
		SceneRegistry.levels["game_start"],
		get_tree().root,
		get_tree().current_scene,
		"wipe_to_right"
	)

func _on_main_menu_pressed() -> void:
	# Reemplaza la escena actual (Lost) por StartScreen
	call_deferred("_go_menu")

func _go_menu() -> void:
	SceneManager.swap_scenes(SceneRegistry.main_scenes["StartScreen"],get_tree().root,get_tree().current_scene,"wipe_to_right"
	)
