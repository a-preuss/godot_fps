extends Node3D
class_name WeaponPickup

#refatorar weapon_manager pra usar signal?
#signal can_pickup_weapon(weapon:WeaponBase, current_clip:int, current_reserve:int)

@export var rigidbody :RigidBody3D
@export var timer :Timer
@export var timer_wait_time :float = 0.3
@export var weapon_name :WeaponBase.Weapons = WeaponBase.Weapons.NONE
@export var weapon_slot :WeaponBase.WeaponSlots
@export var max_clip :int
@export var max_reserve :int
@export var clip_ammo :int
@export var reserve_ammo :int
@export var anim_player :AnimationPlayer
