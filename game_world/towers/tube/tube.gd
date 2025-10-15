extends Tower
class_name Tube

func fire():
	$tube/AnimationPlayer.play("Fire")
	$AirParticles.emitting = true
