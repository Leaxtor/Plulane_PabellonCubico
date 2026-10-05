class_name CamaraCambio
extends Area2D


@export var modo : Modo
@export var modificar_altura : bool = false
@export var altura : int

enum Modo {FIJO, LIBRE}

func _ready() -> void:
	self.body_entered.connect(on_player_enter.bind())

func on_player_enter(_player: Player) -> void:
	if modificar_altura:
		StageManager.camara_modo.emit(modo, altura)
	else:
		StageManager.camara_modo.emit(modo, null)
