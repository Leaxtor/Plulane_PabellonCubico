extends Node2D

const PLAYER_PREFAB := preload("res://Recursos/Scenas/NPC/jugador_plus.tscn")
const STAGE_PREFAB := [
	preload("res://Recursos/Scenas/StageTest2_1.tscn"),
	preload("res://Recursos/Scenas/StageTest2_2.tscn")
]


@onready var stage_transition : StageTransition = $UI/UIContainer/StageTransition
@onready var actors_container : Node2D = $ActoresContenedor
@onready var stage_container : Node2D = $StageContainers
@onready var camara : Camera = $CamaraJugador


var current_stage_index := -1
var camera_initial_position := Vector2.ZERO
var is_stage_ready_for_loading := false
var  player : Player = null

func _process(delta: float) -> void:
	if is_stage_ready_for_loading:
		is_stage_ready_for_loading = false
		var stage : Stage = STAGE_PREFAB[current_stage_index].instantiate()
		stage_container.add_child(stage)
		player = PLAYER_PREFAB.instantiate()
		actors_container.add_child(player)
		camara.jugador = player
		player.position = stage.get_player_spawn_location()
		actors_container.player = player
		camara.position = camera_initial_position
		camara.reset_smoothing()
		stage_transition.end_transition()

func _ready() -> void:
	camera_initial_position = camara.position
	StageManager.stage_intermedio.connect(load_next_stage.bind())
	load_next_stage()
	
func load_next_stage() -> void:
	current_stage_index += 1
	if current_stage_index < STAGE_PREFAB.size():
		
		for actor : Node2D in actors_container.get_children():
			actor.queue_free()
			#pass
		for existing_stage in stage_container.get_children():
			existing_stage.queue_free()
		is_stage_ready_for_loading = true
	
