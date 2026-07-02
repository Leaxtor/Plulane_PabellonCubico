class_name IgorBoss
extends Character

@export var player: Player
@export var distance_from_player : int

func get_target_destination() -> Vector2:
	var target := Vector2.ZERO
	if position.x < player.position.x:
		target = player.position + Vector2.LEFT * distance_from_player
	else:
		target = player.position + Vector2.RIGHT * distance_from_player
	return target
