extends WeaponBase

var delta_timer :float = 0
#var spawn_trail :bool = true
@onready var scene = get_tree().current_scene

func _physics_process(delta:float) -> void:
	delta_timer -= delta
	if delta_timer <= 0:
		if anim_player:
			if anim_player.current_animation == "reload":
				if anim_player.is_playing():
					return
				can_fire = true
				delta_timer = 0
				return
		can_fire = true
		delta_timer = 0

#foi pra weaponbase
#func setup(clip:int, reserve:int):
	#self.current_clip = clip
	#self.reserve_ammo = reserve
#foi pra weaponbase
#func is_clip_empty() -> bool:
	#if current_clip:
		#return false
	#else:
		#clip_empty.emit()
		#return true

func get_reload_amount() -> int: 
		var amount :int = clip_size - current_clip
		if amount <= reserve_ammo:
			return amount
		else:
			return reserve_ammo

func fire(raycast:RayCast3D) -> void:
	if can_fire and not is_clip_empty():
		can_fire = false
		anim_player.play("RESET")
		anim_player.play("fire")
		print("fired")
		current_clip -=1
		#fazer um sinal last_shot pra tocar a animação certa
		if is_clip_empty():
			anim_player.play("last_shot")
			last_shot.emit()
		else:
			fired.emit()
		delta_timer = firerate
		raycast.force_raycast_update()
		var hit :Node = raycast.get_collider()
		var normal :Vector3 = raycast.get_collision_normal()
		var point :Vector3 = raycast.get_collision_point()
		#randf ou 50/50 fixo?
		if hit:
			var decal = decal.instantiate()
			scene.add_child(decal)
			decal.position = point
		if randf() >= 0.5:
			var trail :Node3D = bullet_trail.instantiate()
			scene.add_child(trail)
			trail.global_position = viewmodel_muzzle.global_position
			#precisa dessa checagem pros trails não atravessarem paredes
			if hit:
				trail.target_pos = point
				trail.look_at(point)
			else:
				trail.target_pos = raycast.to_global(raycast.target_position)
				trail.look_at(raycast.to_global(raycast.target_position))
		#spawn_trail = !spawn_trail
		
		if hit is RigidBody3D:
			hit.apply_impulse(-normal * (self.damage * 2) / hit.mass, point - hit.global_position)
		if hit and hit.has_method("take_damage"):
			hit.take_damage(damage)
	else:
		return
	
func reload() -> void:
	if anim_player.current_animation == "reload":
		return
	var a :int = get_reload_amount()
	if not a:
		return
	can_fire = false
	anim_player.play("reload")
	await anim_player.animation_finished
	reserve_ammo -= a
	current_clip += a
	reloading.emit()
	can_fire = true
	#depois de terminar a animação, pode atirar
	#can_fire = true
	#talvez usar um sinal done_reloading também?
