class_name CamaraCambio
extends Area2D


@export var modo : Modo

enum Modo {FIJO, LIBRE}

func _ready() -> void:
	self.body_entered.connect(on_player_enter.bind())

func on_player_enter(_player: Player) -> void:
	print("MODO CAMARA ACTIVADO")
	StageManager.camara_modo.emit(modo)
