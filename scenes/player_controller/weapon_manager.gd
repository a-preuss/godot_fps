extends Node3D

signal update_hud(ammo:Dictionary)

@onready var raycast :RayCast3D = %WeaponRayCast
@onready var player_hands = %WorldModelContainer
@onready var player_viewmodel = %ViewmodelContainer
@onready var pickup_shapecast :ShapeCast3D = self.get_parent().get_node("PickupShapecast")
@export var all_weapons :Array[WeaponBase] #Cena main precisa ter um método pra popular esse array com base nos arquivos.

@onready var acquired_weapons :Array[WeaponBase]
@export var current_slot :int = 0
var current_weapon :WeaponBase
@export var weapon_slots :Array[Node3D]

func slot_is_empty(weapon_slot:Node3D) -> bool:
	if weapon_slot.get_children().is_empty():
		return true
	else:
		return false

func change_current_slot(slot):
	if not slot_is_empty(weapon_slots[slot]):
		current_slot = slot
		current_weapon = weapon_slots[slot].get_child(0)
		update_viewmodel()
		update_worldmodel()
		update_hud.emit(current_weapon.get_current_ammo())

#func play_anim(_anim):
	#var anim_player = current_weapon.viewmodel.get_node_or_null("AnimationPlayer")
	#if anim_player:
		#print("deu certo")
	#else:
		#print("deu errado")
		
func update_worldmodel():
	current_weapon.worldmodel.reparent(player_hands, false)
	current_weapon.worldmodel.position = current_weapon.worldmodel_pos
	current_weapon.worldmodel.rotation = current_weapon.worldmodel_rot
	
func update_viewmodel():
	current_weapon.viewmodel.reparent(player_viewmodel, false)
	current_weapon.viewmodel.position = current_weapon.viewmodel_pos
	current_weapon.viewmodel.rotation = current_weapon.viewmodel_rot
	current_weapon.viewmodel.show()
	

func _ready():
	pass
	
func _physics_process(delta):
	if pickup_shapecast.is_colliding():
		acquire_weapon(pickup_shapecast.get_collider(0))
	
	
func acquire_weapon(weapon:WeaponBase):
	var requested_slot = self.get_child(weapon.weapon_slot)
	if slot_is_empty(requested_slot):
		var new_weapon = weapon.duplicate()
		weapon.queue_free()
		requested_slot.add_child(new_weapon)
	else:
		return
	
func drop_weapon(weapon:WeaponBase):
	pass


func _unhandled_input(event):
	if Input.is_action_just_pressed("primary_weapon"):
		change_current_slot(0)
	elif Input.is_action_just_pressed("secondary_weapon"):
		change_current_slot(1)
	elif Input.is_action_just_pressed("melee_weapon"):
		change_current_slot(2)
	
	if Input.is_action_just_pressed("reload"):
		var weapon = self.get_child(current_slot).get_child(0)
		if weapon:
			self.get_child(current_slot).get_child(0).reload()
			update_hud.emit(current_weapon.get_current_ammo())
		else:
			return
	
	if Input.is_action_just_pressed("primary_fire"):
		if not slot_is_empty(self.get_child(current_slot)):
			self.get_child(current_slot).get_child(0).fire(raycast)
			update_hud.emit(current_weapon.get_current_ammo())
