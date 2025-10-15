extends Projectile
class_name FluteProjectile

func apply(enemy: Enemy):
	super.apply(enemy)
	queue_free()
