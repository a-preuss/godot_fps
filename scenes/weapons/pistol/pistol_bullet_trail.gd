extends Node3D

@export var target_pos := Vector3.ZERO
@export var speed := 200
@export var friction := 500

const MAX_LIFETIME :int = 5000

@onready var spawn_time :int = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float):
	var dir = target_pos - self.global_position
	var add = dir.normalized() * speed * delta
	add = add.limit_length(dir.length())
	self.global_position += add
	#rápido no começo e desacelera, dá um efeito legal
	var slowdown = friction * delta
	speed = max(speed - slowdown, 50)
	if (target_pos - self.global_position).length() <= 1 or Time.get_ticks_msec() - spawn_time > MAX_LIFETIME:
		self.queue_free()
