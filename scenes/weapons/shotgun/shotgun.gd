extends WeaponBase

var spread :int = 3
@onready var scene = get_tree().current_scene

var delta_timer :float = 0

func _physics_process(delta:float) -> void:
	delta_timer -= delta
	if delta_timer <= 0:
		can_fire = true
		delta_timer = 0

func fire(raycast:RayCast3D) -> void:
	if can_fire and not is_clip_empty():
		can_fire = false
		print("fired")
		anim_player.play("RESET")
		anim_player.play("fire")
		#current_clip -=1
		#fazer um sinal last_shot pra tocar a animação certa
		if is_clip_empty():
			last_shot.emit()
		else:
			fired.emit()
		delta_timer = firerate
		for bullet :int in bullets_per_shot:
			raycast.rotation_degrees = Vector3(randf_range(-spread, spread), 0, randf_range(-spread, spread))
			raycast.force_raycast_update()
			#var after_spread :Vector3 = raycast.to_global(raycast.target_position) + Vector3(randf(), randf(),randf())
			var hit :Node = raycast.get_collider()
			var normal :Vector3 = raycast.get_collision_normal()
			var point :Vector3 = raycast.get_collision_point()
			
			#corrigir os trails
			if true:
				var trail :Node3D = bullet_trail.instantiate()
				scene.add_child(trail)
				trail.global_position = viewmodel_muzzle.global_position
				#precisa dessa checagem pros trails não atravessarem paredes
				if hit:
					trail.target_pos = point
					trail.look_at(point)
					var decal = decal.instantiate()
					scene.add_child(decal)
					decal.position = point
				else:
					trail.target_pos = raycast.to_global(raycast.target_position)
					trail.look_at(raycast.to_global(raycast.target_position))
			if hit is PhysicsBody3D:
				hit.apply_impulse(-normal * (self.damage * 2) / hit.mass, point - hit.global_position)
			if hit and hit.has_method("take_damage"):
				hit.take_damage(damage)
			print(hit)
		raycast.rotation_degrees = Vector3.ZERO
	else:
		return
