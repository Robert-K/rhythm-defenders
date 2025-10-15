extends Tower

@onready var area_damage: CollisionShape3D = $AreaDamage/CollisionShape3D

@export var fire_duration: float = 2

func fire():
	
	# Add area damage
	# Play animation
	$maracas/AnimationPlayer.play("FireLoop")
	#area_damage.disabled = false
	await get_tree().create_timer(fire_duration).timeout
	$maracas/AnimationPlayer.stop()
	#area_damage.disabled = true
	
func stop_firing():
	$maracas/AnimationPlayer.stop()
