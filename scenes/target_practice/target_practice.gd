@tool
extends Node3D

#const target_packed: PackedScene = preload("res://target_practice/target.tscn")

@export var target_packed: PackedScene

@export var width: float = 6

@export var height: float = 3

@export var target_lifetime: float = 1

@export var target_spawn_wait_time: float = 2

const SPAWN_Z = 0.11

@onready var areanode =  $Area3D/TargetPracticeArea

@onready var timer: Timer = $TargetSpawnTimer

@onready var areashape = BoxShape3D.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = target_spawn_wait_time
	areashape.size = Vector3(width, height, 0.2)
	areanode.shape = areashape
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	if Engine.is_editor_hint():
		timer = $TargetSpawnTimer
		timer.stop()
		timer.wait_time = target_spawn_wait_time
		areashape.size = Vector3(width, height, 0.2)
		areanode.shape = areashape
		
	else:
		pass
		
		#if timer.is_stopped():
			#print("timer parado")
		#elif not timer.is_stopped():
			#print("timer rodando")
			#print(timer.wait_time)


func _on_timer_timeout():
	print("timer deu timeout")
	var new_target = target_packed.instantiate()
	new_target.lifetime = target_lifetime
	areanode.add_child(new_target)
	new_target.lifetime_over.connect(_on_lifetime_over)
	var half_width: float = width/2
	var half_height: float = height/2
	var new_position: Vector3 = Vector3(randf_range(-half_width, half_width), randf_range(-half_height, half_height), 0.2)
	new_target.position = new_position
	new_target.visible = true
	
	
func _on_lifetime_over(emitter: Target):
	emitter.queue_free()
