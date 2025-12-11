extends Control

var levels := [
	{
		"id": 1,
		"date": "Domingo 01/06/2025",
		"rival": "Chispas vs Belgrano",
		"stadium": "Barrio Pobre FC",
		# CAMBIÁ ESTO por la ruta real de tu escena de juego
		"scene_path": "res://Gameplay/Levels/Level01.tscn",
		"unlocked": true
	}
]

var current_index := 0

@onready var date_label: Label       = %DateLabel
@onready var match_label: Label      = %MatchInfoLabel
@onready var extra_info_label: Label = %ExtraInfoLabel

@onready var play_button: Button     = %PlayButton
@onready var prev_button: Button     = %PrevDateButton
@onready var next_button: Button     = %NextDateButton

@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button     = %ExitButton


func _ready() -> void:
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	_update_view()


func _update_view() -> void:
	var level = levels[current_index]

	date_label.text = level.date
	match_label.text = "Partido: %s" % level.rival
	extra_info_label.text = "Estadio: %s" % level.stadium

	# Habilitar / deshabilitar botón
	play_button.disabled = not level.unlocked

	# Cambiar texto del botón (sin operador ? :)
	if level.unlocked:
		play_button.text = "Jugar partido"
	else:
		play_button.text = "Bloqueado"


func _on_prev_pressed() -> void:
	current_index = (current_index - 1 + levels.size()) % levels.size()
	_update_view()


func _on_next_pressed() -> void:
	current_index = (current_index + 1) % levels.size()
	_update_view()


func _on_play_pressed() -> void:
	var level = levels[current_index]
	if not level.unlocked:
		return
	get_tree().change_scene_to_file(level.scene_path)


func _on_settings_pressed() -> void:
	print("Abrir configuración (ToDo)")


func _on_exit_pressed() -> void:
	get_tree().quit()
