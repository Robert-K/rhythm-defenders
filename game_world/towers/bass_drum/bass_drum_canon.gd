extends Tower

@onready var projectile = preload("res://game_world/damage_dealer/projectile/projectile.tscn")
@onready var projectile_start = $ProjectileStart

@export var projectile_speed: float = 15

func _process(_delta):
	super._process(_delta)
	turn_to_closest_enemy()

func play_anim():
	$bass_drum_canon/AnimationPlayer.play("Fire")
	await $bass_drum_canon/AnimationPlayer.animation_finished

func fire():
	fire_at_target(play_anim, projectile, projectile_start, projectile_speed)
