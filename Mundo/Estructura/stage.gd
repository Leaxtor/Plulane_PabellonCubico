class_name Stage
extends Node2D

@onready var containers : Node2D = $Containers
@onready var checkpoints :  Node2D = $Chechpoints #Checkpoints
@onready var camaraModoColisiones : Node2D = $CamaraModoColisiones
@onready var doors : Node2D = $Doors
@onready var player_spawn_location : Node2D = $PlayerSpawnLocation
@onready var camara_ancla_y : Node2D = $CamaraAnclaY
@export var music: MusicManager.Music

func _init() -> void:
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.camara_modo.connect(on_camara_modo.bind())

func _ready() -> void:
	for container : Node2D in containers.get_children():
		EntityManager.orphan_actor.emit(container)
	#PUERTAS
	for i in range(doors.get_child_count()):
		var door : Door = doors.get_child(i)
		for enemy in door.enemies:
			enemy.assigned_door_index = i
		
	for door : Node2D in doors.get_children():
		EntityManager.orphan_actor.emit(door)
		
	for checkpoint : Checkpoint in checkpoints.get_children():
		checkpoint.create_enemy_data()
	
	
	MusicPlayer.play(music)

func get_player_spawn_location() -> Vector2:
	return player_spawn_location.position

func get_camara_ancla_y() -> int:
	return camara_ancla_y.position.y

func on_checkpoint_complete(_checkpoint : Checkpoint) -> void:
	#StageManager.stage_complete.emit()
	print("Cantidad de checkpoints: " + str(checkpoints.get_children().size()))
	if checkpoints.get_children().size() < 2: #Personalizar para que no siempre se cumpla
	#if checkpoints.get_child(-1) == checkpoint:
		StageManager.stage_complete.emit()

func on_camara_modo(_modo: CamaraCambio.Modo, altura: Variant) -> void:
	if typeof(altura) == TYPE_INT:
		camara_ancla_y.position.y = altura
		#enviar señal a la camara
		StageManager.camara_ancla_update.emit(camara_ancla_y.position.y)
