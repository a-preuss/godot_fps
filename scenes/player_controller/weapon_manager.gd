extends Node3D
class_name WeaponManager

signal update_hud(ammo:Dictionary)

@export var camera :Camera3D
@onready var drop :Node3D = %Drop
@onready var raycast :RayCast3D = %WeaponRayCast
@onready var player_hands :Node3D = %WorldModelContainer
@onready var player_viewmodel :Node3D = %ViewmodelContainer
@onready var pickup_shapecast :ShapeCast3D = %PickupShapecast
#self.get_parent().get_node("PickupShapecast")
@export var all_weapons :Array[WeaponBase] #Cena main precisa ter um método pra popular esse array com base nos arquivos.
@onready var acquired_weapons :Array[WeaponBase]
@onready var gun_audio :AudioStreamPlayer3D = %GunAudio
@onready var dry_fire :AudioStreamPlayer3D = %DryFireAudio
@onready var pickup_audio :AudioStreamPlayer3D = %PickupAudio
@export var current_slot :int = 0
@export var weapon_slots :Array[Node3D]
@export var ammo_pickup_sound :AudioStream
@export var preloader :ResourcePreloader
var current_weapon :WeaponBase
var anim_player :AnimationPlayer

func update_signals(weapon_to_update:WeaponBase = null) -> void:
	if current_weapon:
		if current_weapon.fired.is_connected(_on_weapon_fired):
			current_weapon.fired.disconnect(_on_weapon_fired)
		if current_weapon.clip_empty.is_connected(_on_clip_empty):
			current_weapon.clip_empty.disconnect(_on_clip_empty)
		if current_weapon.last_shot.is_connected(_on_last_shot):
			current_weapon.last_shot.disconnect(_on_last_shot)
		if current_weapon.reloading.is_connected(_on_reloading):
			current_weapon.reloading.disconnect(_on_reloading)
	if weapon_to_update != null:
		weapon_to_update.fired.connect(_on_weapon_fired)
		weapon_to_update.clip_empty.connect(_on_clip_empty)
		weapon_to_update.last_shot.connect(_on_last_shot)
		weapon_to_update.reloading.connect(_on_reloading)
		gun_audio.stream = weapon_to_update.fire_sounds
		dry_fire.stream = weapon_to_update.dry_fire_sound
		#weapon_to_update.is_clip_empty()

func slot_is_empty(weapon_slot:Node3D) -> bool:
	if not weapon_slot.get_child_count():
		return true
	else:
		return false

func change_current_slot(slot:int) -> void:
	if current_slot == slot:
		return
	#if current_weapon:
		#if current_weapon.fired.is_connected(_on_weapon_fired):
			#current_weapon.fired.disconnect(_on_weapon_fired)
		#if current_weapon.clip_empty.is_connected(_on_clip_empty):
			#current_weapon.clip_empty.disconnect(_on_clip_empty)
		#if current_weapon.last_shot.is_connected(_on_last_shot):
			#current_weapon.last_shot.disconnect(_on_last_shot)
		#if current_weapon.reloading.is_connected(_on_reloading):
			#current_weapon.reloading.disconnect(_on_reloading)

	current_slot = slot
	
	if current_weapon:
		current_weapon.unequip()
		current_weapon = null
	
	if slot_is_empty(weapon_slots[current_slot]):
		#update_viewmodel()
		#update_worldmodel()
		update_signals()
		update_hud.emit(null)
		return
	
	current_weapon = weapon_slots[current_slot].get_child(0)
	update_signals(current_weapon)
	current_weapon.equip()
	update_hud.emit(current_weapon.get_current_ammo())

func _on_reloading() -> void:
	update_hud.emit(current_weapon.get_current_ammo())
	##tocar a animação de reload etc
	#current_weapon.can_fire = false
	##animação aqui
	#anim_player.play("RESET")
	#current_weapon.can_fire = true

#fazer o tracer por aqui não resolveu o problema. parece que tem a ver com compilação de shaders.
#func spawn_tracer() -> void:
	#if not current_weapon.bullet_trail:
		#return
	##if randf() >= 0.5:
	#var resource = preloader.get_resource(WeaponBase.Weapons.keys()[current_weapon.weapon_name].to_lower() + "_bullet_trail")
	#var trail = resource.instantiate()
	#get_tree().current_scene.add_child(trail)
	#trail.global_position = drop.global_position
	#trail.target_pos = raycast.to_global(raycast.target_position)
	#trail.look_at(raycast.to_global(raycast.target_position))
#fazer o tracer
func _on_weapon_fired() -> void:
	gun_audio.play()
	#spawn_tracer()
	#if anim_player:
		#anim_player.play("RESET")
		#anim_player.play("fire")

func _on_last_shot() -> void:
	gun_audio.play()
	await get_tree().create_timer(0.1).timeout
	dry_fire.play()
	#anim_player.play("last_shot")

func _on_clip_empty() -> void:
	dry_fire.play()

func get_weapon_of_type(type:AmmoTypes.AmmoTypes) -> WeaponBase:
	for slot :Node3D in weapon_slots:
		if not slot_is_empty(slot):
			if slot.get_child(0).ammo_type == type:
				return slot.get_child(0)
	return null

func _physics_process(_delta:float) -> void:
	if pickup_shapecast.is_colliding():
		var item :Node = pickup_shapecast.get_collider(0)
		print(item)
		if item is WeaponPickup:
			acquire_weapon(item)
		if item is AmmoPickup:
			acquire_ammo(item)

#refatorar pra usar signal?
func acquire_weapon(weapon_pickup:WeaponPickup) -> void:
	var requested_slot :Node3D = weapon_slots[weapon_pickup.weapon_slot]
	if slot_is_empty(requested_slot):
		var resource :Resource = preloader.get_resource(WeaponBase.Weapons.keys()[weapon_pickup.weapon_name].to_lower())
		print(resource)
		var new_weapon :WeaponBase = resource.instantiate()
		weapon_pickup.queue_free()
		requested_slot.add_child(new_weapon)
		new_weapon.setup(weapon_pickup.clip_ammo, weapon_pickup.reserve_ammo)
		if weapon_pickup.weapon_slot == current_slot:
			current_weapon = new_weapon
			current_weapon.equip()
			#update_worldmodel()
			update_signals(current_weapon)
			update_hud.emit(current_weapon.get_current_ammo())
	else:
		return

func acquire_ammo(ammo_pickup:AmmoPickup) -> void:
	#não é pra checar por current weapon
	#tem que checar o tipo do pickup e se o jogador tem uma arma desse tipo
	var weapon :WeaponBase = get_weapon_of_type(ammo_pickup.ammo_type)
	if not weapon:
		return
	if weapon.reserve_ammo == weapon.max_reserve_ammo:
		print("ammo at max")
		return
	var can_acquire :int = weapon.max_reserve_ammo - weapon.reserve_ammo
	print(can_acquire)
	if can_acquire >= ammo_pickup.amount:
		print("acquiring full amount")
		weapon.reserve_ammo += ammo_pickup.amount
	else:
		print("acquiring less than full amount")
		weapon.reserve_ammo += can_acquire
	if pickup_audio.stream:
		pickup_audio.play()
	ammo_pickup.free()
	
	if weapon == current_weapon:
		update_hud.emit(current_weapon.get_current_ammo())
	
func drop_weapon() -> void:
	if slot_is_empty(weapon_slots[current_slot]):
		return
	var scene :Node3D = get_tree().current_scene
	print(current_weapon.weapon_name)
	var resource :Resource = preloader.get_resource(WeaponBase.Weapons.keys()[current_weapon.weapon_name].to_lower() + "_pickup")
	print(WeaponBase.Weapons.keys()[current_weapon.weapon_name].to_lower() + "_pickup")
	var new_weapon :RigidBody3D = resource.instantiate()
	new_weapon.setup(current_weapon.current_clip, current_weapon.reserve_ammo)
	var drop_transform :Transform3D = camera.global_transform
	drop_transform.origin = drop.global_position
	new_weapon.global_transform = drop_transform
	new_weapon.angular_velocity = Vector3.ZERO
	new_weapon.linear_velocity = Vector3.ZERO
	current_weapon.unequip()
	current_weapon.free()
	scene.add_child(new_weapon)
	new_weapon.apply_impulse(-camera.global_transform.basis.z * 15)
	update_hud.emit(null)

func _unhandled_input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("primary_weapon"):
		change_current_slot(0)
	elif Input.is_action_just_pressed("secondary_weapon"):
		change_current_slot(1)
	elif Input.is_action_just_pressed("melee_weapon"):
		change_current_slot(2)
		
	if Input.is_action_just_pressed("drop"):
		drop_weapon()
	
	if Input.is_action_just_pressed("reload"):
		if current_weapon:
			current_weapon.reload()
			update_hud.emit(current_weapon.get_current_ammo())
		else:
			return
	
	if Input.is_action_just_pressed("primary_fire"):
		if current_weapon:
			current_weapon.fire(raycast)
			update_hud.emit(current_weapon.get_current_ammo())
