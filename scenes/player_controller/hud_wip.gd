extends Control


func _on_weapon_manager_update_hud(ammo:Dictionary):
	var label :Label = get_node("Label")
	label.text = str(ammo["current_clip"]) + "/" + str(ammo["reserve_ammo"])
