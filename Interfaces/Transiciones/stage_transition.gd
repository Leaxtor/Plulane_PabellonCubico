class_name StageTransition
extends Control

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func start_transition() -> void:
	animation_player.play("transition_inicio")

func end_transition() -> void:
	animation_player.play("transition_final")

func on_complete_start_transition() -> void:
	animation_player.play("transition_medio")
	StageManager.stage_intermedio.emit()

func on_complete_end_transition() -> void:
	animation_player.play("idle")
