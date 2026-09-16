extends Node2D

const SHOT_PREFAB := preload("res://Mundo/Items/Proyectil/Shot.tscn")

const SPARK_PREFAB := preload("res://Mundo/Items/Proyectil/spark.tscn")

const PREFAB_MAP := {
	Collectible.Type.KNIFE: preload("res://Mundo/Items/Knife_2.tscn"), 
	Collectible.Type.GUN: preload("res://Mundo/Items/Gun_2.tscn"),
	Collectible.Type.FOOD: preload("res://Mundo/Items/Food_2.tscn") 
}

const ENEMY_MAP := {
	Character.Type.ENEMIGO_1: preload("res://NPC/Enemigo_Base1/enemigo_1.tscn"), 
	Character.Type.ENEMIGO_GOON: preload("res://NPC/Enemigo_Base1/enemigo_goon.tscn"),
	Character.Type.THUG_ENEMIGO: preload("res://NPC/Enemigo_Base1/thug_enemigo.tscn"),
	Character.Type.BOSS_TUTORIAL: preload("res://NPC/Sigma/boss_tutorial.tscn")
}

@export var player: Player #El NODO CAPTURA AL JUGADOR PARA DECIRLE A LOS ENEMIGOS QUE IMPRIMA

var doors : Array[Door] = []

func _init () -> void:
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())
	EntityManager.spawn_enemy.connect(on_spawn_enemy.bind())
	EntityManager.orphan_actor.connect(on_orphan_actor.bind())
	EntityManager.spawn_spark.connect(on_spawn_spark.bind())
	DamageManager.player_revive.connect(on_player_revive.bind())
	
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

func on_player_revive() -> void:
	for child in get_children():
		if child is Character:
			var character : Character = child as Character
			if character.type != Character.Type.PLAYER:
				character.on_receive_damage(0, Vector2.ZERO, ReceptorDamage.HitType.KNOCKDOWN)
