extends Node
class_name WeaponBase

signal fired
signal clip_empty
signal last_shot
signal reloading

enum Weapons {
	NONE,
	PISTOL,
	SHOTGUN,
}

enum WeaponSlots {
	PRIMARY,
	SECONDARY,
	MELEE
}

enum FiringBehavior {
	AUTO,
	SEMIAUTO,
	CHARGEFIRE
}

var can_fire :bool = true
@export var weapon_name :Weapons = Weapons.NONE
@export_category("Ammo Variables")

@export var max_reserve_ammo :int
@export var reserve_ammo :int
@export var clip_size :int
@export var current_clip :int = clip_size
@export var ammo_type :AmmoTypes.AmmoTypes

@export_category("Mechanical Parameters")

## Timer
#usando timer com delta agora
#@export var firerate_timer :Timer
## Time value for firerate_timer, in seconds.
@export_range(0.1, 3, 0.01) var firerate :float
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

@export var fire_sounds :AudioStreamRandomizer
@export var reload_sounds :AudioStreamRandomizer
@export var dry_fire_sound :AudioStreamRandomizer
@export var low_ammo_sound :AudioStream

@export_category("Weapon Models")
#Viewmodel
@export var viewmodel :PackedScene
@export var viewmodel_pos :Vector3 = Vector3.ZERO
@export var viewmodel_rot :Vector3 = Vector3.ZERO
@export var viewmodel_scale :Vector3 = Vector3.ONE
#Bullet trail
#troquei por preload pq tava travando o jogo
#continuou travando? não sei o que fazer
@export var bullet_trail :PackedScene
@export var decal :PackedScene
#Worldmodel
@export var worldmodel :PackedScene
@export var worldmodel_pos :Vector3 = Vector3.ZERO
@export var worldmodel_rot :Vector3 = Vector3.ZERO
@export var worldmodel_scale :Vector3 = Vector3.ONE

@onready var weapon_manager :WeaponManager = get_parent().get_parent()
var viewmodel_instance :Node3D
var anim_player :AnimationPlayer
var viewmodel_muzzle :Node3D

func get_current_ammo() -> Dictionary:
	return {
		"current_clip" = current_clip,
		"reserve_ammo" = reserve_ammo
	}

func equip():
	#instanciar viewmodel, 
	#manter referência do animplayer pra poder gerenciar as animações no script da arma,
	#tocar a animação de equipar
	if viewmodel:
		viewmodel_instance = viewmodel.instantiate()
	anim_player = viewmodel_instance.get_node_or_null("AnimationPlayer")
	weapon_manager.player_viewmodel.add_child(viewmodel_instance)
	if anim_player.has_animation("empty") and is_clip_empty():
		anim_player.play("empty")
	viewmodel_instance.position = viewmodel_pos
	viewmodel_instance.rotation = viewmodel_rot
	viewmodel_muzzle = viewmodel_instance.get_node("Muzzle")
	viewmodel_instance.show()

func unequip():
	#tocar a animação de desequipar,
	#dar free no viewmodel
	viewmodel_instance.free()
	viewmodel_muzzle = null
	viewmodel_instance = null

func setup(clip:int, reserve:int):
	self.current_clip = clip
	self.reserve_ammo = reserve

func is_clip_empty() -> bool:
	if current_clip:
		return false
	else:
		clip_empty.emit()
		return true

#implementar especificamente
func fire(_raycast):
	pass

#implementar especificamente
func reload():
	pass

#implementar especificamente
func secondary_fire():
	pass
