extends CharacterBody3D

var hp :float = 100

func take_damage(damage):
	hp -= damage
	if hp <= 0:
		#morrer
		pass
