class_name Enemigo_1
extends Character

@export var player : Player

var player_slot : EnemigoSlot = null 

func handle_input() -> void:
	if player != null and can_move() :
		
		if player_slot == null:
			player_slot = player.reserve_slot(self)
			
		if player_slot != null:
			var direction := (player_slot.global_position - position).normalized()
			if (player_slot.global_position - global_position).length() < 3:
				velocity = Vector2.ZERO
			else:
				velocity = direction * move_speed 
				
	#func damage_received(damage: int, direccion: Vector2) -> void:
	#	super.damage_received(damage, direccion)
	#	if current_health == 0:
	#		player.free_slot(self)


func on_receive_damage(amount: int, direccion: Vector2, hit_Type: ReceptorDamage.HitType) -> void:
	super.on_receive_damage(damage, direccion, hit_Type)
	if current_health == 0:
			player.free_slot(self)
