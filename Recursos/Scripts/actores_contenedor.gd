extends Node2D

const SHOT_PREFAB := preload("res://Recursos/Scenas/Miselaneos/Shot.tscn")

const PREFAB_MAP := {
	Collectible.Type.KNIFE: preload("res://Recursos/Scenas/Miselaneos/Knife.tscn"), 
	Collectible.Type.GUN: preload("res://Recursos/Scenas/Miselaneos/Gun.tscn"),
	Collectible.Type.FOOD: preload("res://Recursos/Scenas/Miselaneos/Food.tscn") 
}

func _ready() -> void:
	EntityManager.spawn_collectible.connect(on_spawn_collectible.bind())
	EntityManager.spawn_shot.connect(on_spawn_shot.bind())
	
func on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectible_direction: Vector2, initial_height: float, autodestroy: bool) -> void:
	var collectible : Collectible = PREFAB_MAP[type].instantiate()
	collectible.state = initial_state
	collectible.height = initial_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectible_direction
	collectible.autodestroy = autodestroy
	add_child.call_deferred(collectible) #add child pero se ejecuta luego de calcular la fisica
	#call_deferred("add_child", collectible) forma vieja del tutorial
	#add_child(collectible)
	#el "knockdown_intensity" determina que tanto va a girar en el aire
func on_spawn_shot(gun_root_position: Vector2, distance_traveled: float, height: float) -> void:
	var shot: Shot = SHOT_PREFAB.instantiate()
	add_child(shot)
	shot.position = gun_root_position
	shot.initialize(distance_traveled, height)
