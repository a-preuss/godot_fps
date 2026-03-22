extends Node3D
class_name Target

@onready var timer: Timer = $LifeTime

signal lifetime_over(emitter:Target)

var lifetime: float = 1

var size_scale: float = 1

func toggle_node():
	if self.visible:
		self.hide()
	else:
		self.show()
	
func _init():
	self.visible = false
	
	print("init do target chamado")

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = lifetime
	timer.start()
	if not timer.is_stopped():
		print("timer do target rodando")

func _on_life_time_timeout():
	print("timer do target acabou")
	emit_signal("lifetime_over", self)
