extends Node2D

const SHOT_PREFAB := preload("res://Recursos/Scenas/Miselaneos/Shot.tscn")

const SPARK_PREFAB := preload("res://Recursos/Scenas/Miselaneos/spark.tscn")

const PREFAB_MAP := {
	Collectible.Type.KNIFE: preload("res://Recursos/Scenas/Miselaneos/Knife.tscn"), 
	Collectible.Type.GUN: preload("res://Recursos/Scenas/Miselaneos/Gun.tscn"),
	Collectible.Type.FOOD: preload("res://Recursos/Scenas/Miselaneos/Food.tscn") 
}

const ENEMY_MAP := {
	Character.Type.ENEMIGO_1: preload("res://Recursos/Scenas/NPC/enemigo_1.tscn"), 
	Character.Type.ENEMIGO_GOON: preload("res://Recursos/Scenas/NPC/enemigo_goon.tscn"),
	Character.Type.THUG_ENEMIGO: preload("res://Recursos/Scenas/NPC/thug_enemigo.tscn"),
	Character.Type.BOSS_TUTORIAL: preload("res://Recursos/Scenas/NPC/boss_tutorial.tscn")
}

@export var player: Player #El NODO CAPTURA AL JUGADOR PARA DECIRLE A LOS ENEMIGOS QUE IMPRIMA

var doors : Array[Door] = []

func _init () -> void:
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())
	EntityManager.orphan_actor.connect(on_orphan_actor.bind())
	EntityManager.spawn_spark.connect(on_spawn_spark.bind())
	
func on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectible_direction: Vector2, initial_height: float, autodestroy: bool) -> void:
	var collectible : Collectible = PREFAB_MAP[type].instantiate()
	collectible.state = initial_state
	collectible.height = initial_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectible_direction
	collectible.autodestroy = autodestroy
	add_child.call_deferred(collectible) #add child pero se ejecuta luego de calcular la fisica
	#call_deferred("add_child", collectible) forma vieja del tutorial
	
	#el "knockdown_intensity" determina que tanto va a girar en el aire

func on_spawn_shot(gun_root_position: Vector2, distance_traveled: float, height: float) -> void:
	var shot: Shot = SHOT_PREFAB.instantiate()
	add_child(shot)
	shot.position = gun_root_position
	shot.initialize(distance_traveled, height)

func on_spawn_enemy(enemy_data: EnemyData) -> void:
	var enemy : Character = ENEMY_MAP[enemy_data.type].instantiate()
	print("POSICION GLOBAL ENEMIGO ", enemy_data.global_position)
	enemy.global_position = enemy_data.global_position
	enemy.player = player #EL enemigo debe fijar al jugador
	enemy.height = enemy_data.height
	enemy.state = enemy_data.state
	if enemy_data.door_index > -1:
		enemy.assign_door(doors[enemy_data.door_index])
	add_child(enemy) 

func on_spawn_spark(spark_position: Vector2) -> void:
	var spark_instance :=  SPARK_PREFAB.instantiate()
	spark_instance.position = spark_position
	add_child(spark_instance)

func on_orphan_actor(orphan: Node2D) -> void:
	if orphan is Door:
		doors.append(orphan)
	orphan.reparent(self)
