extends Tower

@onready var projectile = preload("res://game_world/towers/projectiles/projectile.tscn")
@onready var projectile_start = $ProjectileStart

func fire():
	$bass_drum_canon/AnimationPlayer.play("Fire")
	await $bass_drum_canon/AnimationPlayer.animation_finished
	var node : Projectile = projectile.instantiate()
	projectile_start.add_child(node)
	node.apply_central_impulse(Vector3(10, 0, 0))
