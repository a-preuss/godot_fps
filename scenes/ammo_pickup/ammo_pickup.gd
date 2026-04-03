extends AmmoPickup
#refatorar pra usar signal
func _init(current_amount = 0):
	if current_amount:
		amount = current_amount

func _ready():
	if self.model:
		var current_model = self.model.instantiate()
		self.get_node("AmmoModel").add_child(current_model)
		current_model.get_node_or_null("AnimationPlayer").play("rotate")
	
	
