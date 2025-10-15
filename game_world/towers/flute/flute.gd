extends Tower

@onready var projectile = preload("res://game_world/damage_dealer/projectile/flute_projectile.tscn")
@onready var projectile_start = $ProjectileStart

@export var projectile_speed: float = 45

func _process(_delta):
	super._process(_delta)
	turn_to_closest_enemy()

func play_anim():
	$flute/AnimationPlayer.play("Fire")
	await $flute/AnimationPlayer.animation_finished

func fire():
	fire_at_target(play_anim, projectile, projectile_start, projectile_speed, Vector3(0, PI / 2, 0))
