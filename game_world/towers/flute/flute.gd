extends Tower
class_name Flute

@onready var projectile = preload("res://game_world/damage_dealer/projectile/flute_projectile.tscn")
@onready var projectile_start = $ProjectileStart

func _process(_delta):
	turn_to_last_enemy()

func play_anim():
	$flute/AnimationPlayer.play("Fire")
	await $flute/AnimationPlayer.animation_finished

func fire():
	fire_at_target(play_anim, projectile, projectile_start, Vector3(0, PI / 2, 0))
