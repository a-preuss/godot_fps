extends Control

@export var movespeed_label :Label

func _on_weapon_manager_update_hud(ammo):
	var label :Label = get_node("Label")
	if ammo == null:
		label.text = ""
		
	if ammo is Dictionary:
		label.text = str(ammo["current_clip"]) + "/" + str(ammo["reserve_ammo"])

func _physics_process(_delta):
	movespeed_label.text = str(get_parent().velocity.length())
