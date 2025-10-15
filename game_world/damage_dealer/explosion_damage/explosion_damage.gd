extends DamageDealer
class_name ExplosionDamage

func apply(enemy: Enemy):
	enemy.apply_damage(damage)
