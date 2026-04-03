extends CSGCylinder3D

signal hit

func take_damage(_damage: float):
	print("hit!")
	hit.emit()
