class_name UI
extends CanvasLayer


@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthBar
@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthBar
@onready var combo_indicator : ComboIndicator = $UIContainer/CombiIndicator
@onready var score_indicator : ScoreIndicator = $UIContainer/ScoreIndicator

@export var duration_healthbar_visible : int

var time_start_healthbar_visible := Time.get_ticks_msec()

const avatar_map : Dictionary = {
	Character.Type.ENEMIGO_1: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.ENEMIGO_GOON: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.THUG_ENEMIGO: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.BOSS_TUTORIAL: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarSigma.png")
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())

func _process(delta: float) -> void:
	if enemy_healthbar.visible and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_healthbar.visible = false

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false
	combo_indicator.combo_reset.connect(on_combo_reset.bind())
	
func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)

func on_character_health_change(type: Character.Type, current_health: int, max_health: int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_healthbar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_healthbar.visible = true
		 
