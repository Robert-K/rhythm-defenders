extends Tower

func fire():
	$tube/AnimationPlayer.play("Fire")
	$AirParticles.emitting = true
