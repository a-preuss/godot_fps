extends WeaponBase


func is_clip_empty() -> bool:
	if current_clip:
		return false
	else:
		return true

func get_reload_amount(): 
		var amount = clip_size - current_clip
		if amount <= reserve_ammo:
			return amount
		else:
			return reserve_ammo

func _ready():
	self.viewmodel.hide()
	firerate_timer.start()


func fire(raycast:RayCast3D):
	if can_fire and not is_clip_empty():
		viewmodel_anim_player.play("RESET")
		can_fire = false
		firerate_timer.start()
		print("pew")
		current_clip -=1
		print(current_clip)
		viewmodel_anim_player.play("fire")
		raycast.force_raycast_update()
		var hit = raycast.get_collider()
		if hit and hit.has_method("take_damage"):
			hit.take_damage(damage)
	else:
		return
	
func reload():
	var a = get_reload_amount()
	if not a:
		return
	reserve_ammo -= a
	current_clip += a

func _on_timer_timeout():
	can_fire = true
