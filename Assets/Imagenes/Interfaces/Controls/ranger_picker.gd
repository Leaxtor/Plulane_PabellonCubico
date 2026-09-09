class_name RangePicker
extends ActivableControl

const TICK_OFF  := preload("res://Assets/Imagenes/Interfaces/Controls/cuadradoblanco.png")
const TICK_ON := preload("res://Assets/Imagenes/Interfaces/Controls/cuadradoblanco2.png")

@onready var ticks_container : HBoxContainer = $TicksContainer

func refresh() -> void:
	#El tipado se volvio más estricto con una actualizacion ya no sirve.
	#var ticks : Array[TextureRect] = ticks_container.get_children()
	var ticks := ticks_container.get_children() # as Array[TextureRect]
	for i in range(0, current_value):
		ticks[i].texture = TICK_ON
	for i in range(current_value, ticks.size()):
		ticks[i].texture = TICK_OFF

func _process(delta: float) -> void:
	if is_active and Input.is_action_just_pressed("move_left"):
		set_value(current_value - 1)
	if is_active and Input.is_action_just_pressed("move_right"):
		set_value(current_value + 1)
