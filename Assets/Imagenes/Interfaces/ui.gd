class_name UI
extends CanvasLayer

const OPTION_SCREEN_PREFAB := preload("res://Assets/Imagenes/Interfaces/OptionScreen.tscn")
const DEATH_SCREEN_PREFAB := preload("res://Assets/Imagenes/Interfaces/death_scene.tscn")
const GAMEOVER_SCREEN_PREFAB := preload("res://Assets/Imagenes/Interfaces/GameoverScreen.tscn")

@onready var player_healthbar : Healthbar = $UIContainer/PlayerHealthBar
@onready var enemy_avatar : TextureRect = $UIContainer/EnemyAvatar
@onready var enemy_healthbar : Healthbar = $UIContainer/EnemyHealthBar
@onready var go_indicator : FlickeringTextureRect = $UIContainer/GoIndicator
@onready var combo_indicator : ComboIndicator = $UIContainer/CombiIndicator
@onready var score_indicator : ScoreIndicator = $UIContainer/ScoreIndicator
@onready var stage_transition : StageTransition = $UIContainer/StageTransition

@export var duration_healthbar_visible : int

var game_over_screen : GameOverScreen = null
var death_screen : DeathScene = null
var option_screen : OptionsScreen = null
var time_start_healthbar_visible := Time.get_ticks_msec()

const avatar_map : Dictionary = {
	Character.Type.ENEMIGO_1: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.ENEMIGO_GOON: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.THUG_ENEMIGO: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarEnemy.png"),
	Character.Type.BOSS_TUTORIAL: preload("res://Assets/Imagenes/NPC/Personajes_principales/Plus/AvatarSigma.png")
}

func _init() -> void:
	DamageManager.health_change.connect(on_character_health_change.bind())
	StageManager.checkpoint_complete.connect(on_checkpoint_complete.bind())
	StageManager.stage_complete.connect(on_stage_complete.bind())

func _process(delta: float) -> void:
	if enemy_healthbar.visible and (Time.get_ticks_msec() - time_start_healthbar_visible > duration_healthbar_visible):
		enemy_avatar.visible = false
		enemy_healthbar.visible = false
	handle_input()

func _ready() -> void:
	enemy_avatar.visible = false
	enemy_healthbar.visible = false
	combo_indicator.combo_reset.connect(on_combo_reset.bind())

func handle_input() -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if option_screen == null: #Revisa si existe una pantalla options
			option_screen = OPTION_SCREEN_PREFAB.instantiate()
			option_screen.exit.connect(unpause) #PROBLEMA AL VOLVER CON ACCION activa la accion
			add_child(option_screen)
			get_tree().paused = true
		else:
			unpause() #VOLVER PRESIONANDO ESC
	
func unpause() -> void:
	option_screen.queue_free()
	get_tree().paused = false
	
func on_combo_reset(points: int) -> void:
	score_indicator.add_combo(points)

func on_character_health_change(type: Character.Type, current_health: int, max_health: int) -> void:
	if type == Character.Type.PLAYER:
		player_healthbar.refresh(current_health, max_health)
		print("Vida actual")
		print(current_health)
		if current_health == 0 and death_screen == null:
			print("MUERTO")
			death_screen = DEATH_SCREEN_PREFAB.instantiate()
			death_screen.game_over.connect(on_game_over.bind())
			add_child(death_screen)
			
	else:
		time_start_healthbar_visible = Time.get_ticks_msec()
		enemy_avatar.texture = avatar_map[type]
		enemy_healthbar.refresh(current_health, max_health)
		enemy_avatar.visible = true
		enemy_healthbar.visible = true

func on_game_over() -> void:
	if game_over_screen == null:
		game_over_screen = GAMEOVER_SCREEN_PREFAB.instantiate()
		game_over_screen.set_score(score_indicator.real_score)
		add_child(game_over_screen)

func on_checkpoint_complete(_checkpoint: Checkpoint) -> void:
	go_indicator.start_flickering()
	

func on_stage_complete() -> void:
	stage_transition.start_transition()
