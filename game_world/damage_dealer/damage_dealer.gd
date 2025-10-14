extends Node3D
class_name DamageDealer

@export var damage: float

func apply(enemy: Enemy):
	enemy.apply_damage(damage)
