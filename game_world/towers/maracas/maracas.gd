extends Tower

@onready var area_damage: CollisionShape3D = $AreaDamage/CollisionShape3D

@export var fire_duration: float = 2

var firing = false
var floor_damage = 0.0

func fire():
	# Add area damage
	# Play animation
	$maracas/AnimationPlayer.play("FireLoop")
	firing = true
	#area_damage.disabled = false
	await get_tree().create_timer(fire_duration).timeout
	$maracas/AnimationPlayer.stop()
	#area_damage.disabled = true
	firing = false
	
func stop_firing():
	$maracas/AnimationPlayer.stop()
	firing = false

func _process(_delta):
	if firing:
		floor_damage += _delta*0.5
	else:
		floor_damage -= _delta*0.5
	floor_damage = clamp(floor_damage, 0.0, 1.0)
	
	var color : Color = $Sprite3D.modulate
	color.a = floor_damage
	$Sprite3D.modulate = color
