class_name Enemigo_1
extends Character

@export var player : Player
@export var duracion_entre_ataques : int
@export var duracion_preparando_ataque : int


var player_slot : EnemigoSlot = null 
var time_duracion_last_hit := Time.get_ticks_msec()
var time_duracion_preparando_ataque := Time.get_ticks_msec()	

func _ready() ->void:
	super._ready()
	anim_attack = ["plus_animacion/Golpe","plus_animacion/Golpe_2"]


func handle_input() -> void:
	if player != null and can_move() :
		
		if player_slot == null:
			player_slot = player.reserve_slot(self)
			
		if player_slot != null:
			var direction := (player_slot.global_position - position).normalized()
			if is_player_within_range():
				velocity = Vector2.ZERO
				if can_accion() :
					state = State.Preparar_Ataque
					time_duracion_preparando_ataque = Time.get_ticks_msec()
			else:
				velocity = direction * move_speed 

#func handle_prep_attack() -> void:
#	 if state == State.Preparar_Ataque and (Time.get_ticks_msec() - time_duracion_last_hit > duracion_preparando_ataque):
#		state = State.Golpe

func handle_prep_attack() -> void:
	if state == State.Preparar_Ataque and (Time.get_ticks_msec() - time_duracion_preparando_ataque > duracion_preparando_ataque):
		state = State.Golpe
		time_duracion_last_hit  = Time.get_ticks_msec()
		anim_attack.shuffle()

func is_player_within_range():
	return (player_slot.global_position - global_position).length() < 3

func can_accion() -> bool:
	if Time.get_ticks_msec() - time_duracion_last_hit < duracion_entre_ataques:
		return false
	return super.can_accion()


func set_heading() -> void:
	if player == null:
		return
	heading = Vector2.LEFT if position.x > player.position.x else Vector2.RIGHT

func on_receive_damage(amount: int, direccion: Vector2, hit_Type: ReceptorDamage.HitType) -> void:
	super.on_receive_damage(amount, direccion, hit_Type)
	if current_health == 0:
			player.free_slot(self)
