extends CSGCylinder3D

func take_damage(_damage: float):
	print("hit!")
	get_parent().queue_free()
