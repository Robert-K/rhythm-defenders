extends Tower
class_name Maracas

@onready var damage_area: AreaDamage = $AreaDamage

var firing = false
var floor_damage = 0.0

func fire():
	# Play animation
	$maracas/AnimationPlayer.play("FireLoop")
	firing = true
	
	# Enable area damage
	damage_area.enable()

func stop_firing():
	$maracas/AnimationPlayer.stop()
	firing = false
	
	damage_area.disable()

func _process(_delta):	
	# Floor damage visuals
	if firing:
		floor_damage += _delta*0.5
	else:
		floor_damage -= _delta*0.5
	floor_damage = clamp(floor_damage, 0.0, 1.0)
	
	if firing == false and floor_damage == 0:
		turn_to_closest_enemy()
	
	var color : Color = $Sprite3D.modulate
	color.a = floor_damage
	$Sprite3D.modulate = color
