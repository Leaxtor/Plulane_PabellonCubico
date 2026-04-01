class_name Enemigo1
extends Character

@export var node2d: Node2D

func handle_input() -> void:
	if node2d != null:
		var direction := (node2d.position - position).normalized()
		velocity = direction * move_speed
