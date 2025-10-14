extends Tower

@onready var projectile = preload("res://game_world/towers/projectiles/projectile.tscn")
@onready var projectile_start = $ProjectileStart

func _process(_delta):
	super._process(_delta)
	turn_to_closest_enemy()

func fire():
	if (target_enemy == null):
		return
	
	var dist = global_position.distance_to(target_enemy.global_position)
	if (dist > radius):
		return
	
	$bass_drum_canon/AnimationPlayer.play("Fire")
	await $bass_drum_canon/AnimationPlayer.animation_finished
	var node : Projectile = projectile.instantiate()
	projectile_start.add_child(node)
	node.damage = damage
	node.global_position = projectile_start.global_position
	var target_vector = global_position.direction_to(target_enemy.global_position)
	node.apply_central_impulse(target_vector * 15)
