extends WeaponPickup

func _ready():
	timer.wait_time = timer_wait_time
	#rigidbody.set_collision_layer_value(1, false)
	rigidbody.set_collision_layer_value(8, false)
	if clip_ammo == 0:
		anim_player.play("empty")

func _on_timer_timeout():
	#ter colisão na camada do jogador causa comportamentos indesejados
	#dropar a arma encostado numa parede empurra o jogador
	#rigidbody.set_collision_layer_value(1, true)
	rigidbody.set_collision_layer_value(8, true)


func setup(clip:int, reserve:int):
	self.clip_ammo = clip
	self.reserve_ammo = reserve
	if clip_ammo == 0:
		anim_player.play("empty")
