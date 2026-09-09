class_name Stage
extends Node2D

@onready var containers : Node2D = $Containers
@onready var checkpoints :  Node2D = $Chechpoints #Checkpoints
@onready var doors : Node2D = $Doors
@onready var player_spawn_location : Node2D = $PlayerSpawnLocation
@export var music: MusicManager.Music

func _init() -> void:
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())

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

func on_checkpoint_complete(checkpoint : Checkpoint) -> void:
	#StageManager.stage_complete.emit()
	print("Cantidad de checkpoints: " + str(checkpoints.get_children().size()))
	print(checkpoints.get_children(0))
	if checkpoints.get_children().size() < 2: #Personalizar para que no siempre se cumpla
	#if checkpoints.get_child(-1) == checkpoint:
		StageManager.stage_complete.emit()
	
