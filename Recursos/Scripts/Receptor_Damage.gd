class_name ReceptorDamage
extends Area2D
enum HitType {NORMAL, KNOCKDOWN, POWER}
signal damage_received(damage: int, direccion: Vector2, hit_type: HitType)
