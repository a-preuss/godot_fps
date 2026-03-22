extends Node
class_name WeaponBase


enum WeaponSlots {
	PRIMARY,
	SECONDARY,
	MELEE
}

enum AmmoTypes {
	PISTOL,
	RIFLE,
	SHOTGUN,
	OTHER
}

enum FiringBehavior {
	AUTO,
	SEMIAUTO,
	CHARGEFIRE
}

var can_fire :bool = false

@export_category("Ammo Variables")

@export var max_reserve_ammo :int
@export var clip_size :int
@export var current_clip :int = clip_size
@export var reserve_ammo :int
@export var ammo_type :AmmoTypes

@export_category("Mechanical Parameters")

## Timer
@export var firerate_timer :Timer
## Time value for firerate_timer, in seconds.
@export var firerate :float = 0.5
## Bullets fired per single shot. Shotguns might have higher values, etc.
@export var bullets_per_shot :int
@export var damage :float
@export var weapon_range :int
@export var is_hitscan :bool
## Weapon dependent move speed multiplier
@export var move_speed :float
@export var firing_behavior :FiringBehavior
## Which slot this weapon occupies
@export var weapon_slot :WeaponSlots

#Parametros pra caso seja uma arma de carregar
@export var charge_time :float
@export var must_fully_charge :bool


@export_category("Weapon Sounds")

@export var fire_sounds :Array[AudioStream]
@export var reload_sounds :Array[AudioStream]
@export var dry_fire_sound :Array[AudioStream]
@export var low_ammo_sound :AudioStream

@export_category("Weapon Models")
#Viewmodel
@export var viewmodel_anim_player :AnimationPlayer
@export var viewmodel :Node3D
@export var viewmodel_pos := Vector3.ZERO
@export var viewmodel_rot := Vector3.ZERO
@export var viewmodel_scale := Vector3.ONE
#Worldmodel
@export var worldmodel :Node3D
@export var worldmodel_pos := Vector3.ZERO
@export var worldmodel_rot := Vector3.ZERO
@export var worldmodel_scale := Vector3.ONE

func get_current_ammo() -> Dictionary:
	return {
		"current_clip" = current_clip,
		"reserve_ammo" = reserve_ammo
	}

func fire(raycast:RayCast3D):
	pass

func reload():
	pass

func secondary_fire():
	pass
