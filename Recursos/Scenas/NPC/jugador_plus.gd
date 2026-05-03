class_name Player
extends Character

@onready var enemy_slots : Array =$EnemySlots.get_children()


func _ready() ->void:
	super._ready()
	anim_attack = ["plus_animacion/Golpe","plus_animacion/Golpe_2","plus_animacion/Golpe_3","plus_animacion/Golpe_4"]


func handle_input() -> void:
	var direction := Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * move_speed
	if can_accion() and Input.is_action_just_pressed("ataque_golpear"):
		state = State.Golpe
		if is_ultimo_hit_acertado:
			#Avanza 1 x 1 en la lista de animaciones de ataque y obtiene el resto, dando la vuelta si se pasa
			attack_combo_index = (attack_combo_index+1) % anim_attack.size()
			is_ultimo_hit_acertado = false
		else:
			attack_combo_index = 0
	if can_accion() and Input.is_action_just_pressed("move_bloqueo"):
		state = State.Bloqueo
	if can_jump() and Input.is_action_just_pressed("move_saltar"):
		state = State.Salto_Inicio
	if can_jump_patada() and Input.is_action_just_pressed("ataque_golpear"):
		state = State.Salto_Patada

func set_heading() -> void:
	if velocity.x > 0:
		heading = Vector2.RIGHT
	elif velocity.x < 0:
		heading = Vector2.LEFT

func reserve_slot(enemy: Enemigo_1) -> EnemigoSlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	available_slots.sort_custom(
		func(a: EnemigoSlot, b: EnemigoSlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]
	
func free_slot(enemy: Enemigo_1) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemigoSlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()
