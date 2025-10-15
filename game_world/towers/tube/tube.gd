extends Tower
class_name Tube

@onready var projectile = preload("res://game_world/damage_dealer/projectile/tube_projectile.tscn")
@onready var projectile_start = $ProjectileStart

func _process(_delta):
	turn_to_closest_enemy()

func play_anim():
	$tube/AnimationPlayer.play("Fire")

func fire():
	fire_at_target(play_anim, projectile, projectile_start)
