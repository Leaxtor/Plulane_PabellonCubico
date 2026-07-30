class_name  EnemyData
extends Resource

const DROP_HEIGHT := 150

@export var height : int
@export var type : Character.Type
@export var global_position : Vector2
@export var state : Character.State

func _init(character_type: Character.Type = Character.Type.ENEMIGO_1, position: Vector2 = Vector2.ZERO) -> void:
	type = character_type
	global_position = position
	if position.y<0:
		height = DROP_HEIGHT
		global_position = position + Vector2.DOWN *  DROP_HEIGHT
	else: 
		global_position = position
		state = Character.State.Reposo
