extends Control

# Cada entrada representa una "fecha" / nivel
var levels := [
	{
		"id": 1,
		"date": "01/06/2025",
		"rival": "Defensor Novato",
		"stadium": "Cancha del Cole",
		"scene_path": "res://scenes/Level1.tscn",
		"unlocked": true
	},
	{
		"id": 2,
		"date": "05/06/2025",
		"rival": "Defensor Rápido",
		"stadium": "Estadio Municipal",
		"scene_path": "res://scenes/Level2.tscn",
		"unlocked": false
	},
	{
		"id": 3,
		"date": "10/06/2025",
		"rival": "Defensor Elite",
		"stadium": "Estadio Nacional",
		"scene_path": "res://scenes/Level3.tscn",
		"unlocked": false
	}
]

var current_index: int = 0

@onready var date_label: Label        = %DateLabel
@onready var match_label: Label       = %MatchInfoLabel
@onready var extra_info_label: Label  = %ExtraInfoLabel
@onready var play_button: Button      = %PlayButton
@onready var prev_button: Button      = %PrevDateButton
@onready var next_button: Button      = %NextDateButton
@onready var settings_button: Button  = %SettingsButton
@onready var exit_button: Button      = %ExitButton

func _ready() -> void:
	# Conectar señales de los botones
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	_update_view()

func _update_view() -> void:
	var level = levels[current_index]
	
	# Mostrar fecha y datos del partido
	date_label.text = level.date
	match_label.text = "Fecha %d - vs. %s" % [level.id, level.rival]
	extra_info_label.text = "Estadio: %s" % level.stadium
	
	# Si no está desbloqueado, deshabilitamos el botón y mostramos algo
	if level.unlocked:
		play_button.disabled = false
		play_button.text = "Jugar partido"
	else:
		play_button.disabled = true
		play_button.text = "Bloqueado"

func _on_prev_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = levels.size() - 1  # vuelve al último
	_update_view()

func _on_next_pressed() -> void:
	current_index += 1
	if current_index >= levels.size():
		current_index = 0  # vuelve al primero
	_update_view()

func _on_play_pressed() -> void:
	var level = levels[current_index]
	if not level.unlocked:
		return
	# Cambia a la escena del nivel elegido
	get_tree().change_scene_to_file(level.scene_path)

func _on_settings_pressed() -> void:
	# Más adelante podés cargar otra escena o abrir un popup
	# Ejemplo sencillo: cambiar escena a Settings
	# get_tree().change_scene_to_file("res://scenes/Settings.tscn")
	print("Abrir menú de configuración (ToDo)")

func _on_exit_pressed() -> void:
	# En Android normalmente se maneja con la tecla atrás,
	# pero para debug en PC esto viene bien:
	get_tree().quit()
