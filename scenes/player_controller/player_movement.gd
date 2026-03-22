extends Node

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left: String = "ui_left"
## Name of Input Action to move Right.
@export var input_right: String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward: String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back: String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump: String = "ui_accept"

@export_group("Movement Options")

@export var walk_speed: float = 7.0
@export var sprint_speed :float = 8.5
@export var ground_accel: float = 14
@export var ground_friction: float = 10
@export var jump_velocity: float = 6.0
@export var auto_bhop: bool = false
@export var air_accel: float = 800
@export var air_cap: float = 0.85
@export var air_move_speed: float = 500

var wish_dir: Vector3 = Vector3.ZERO

@onready var character: CharacterBody3D = get_parent()

func get_move_speed():
	#valor temporário
	#implementar walk depois
	return sprint_speed


func _handle_air_physics(delta: float) -> void:
	character.velocity.y += character.get_gravity().y * delta #gravidade vem como um valor negativo usando esse método
	var current_speed_in_wish_dir = character.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_till_cap = capped_speed - current_speed_in_wish_dir
	if add_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_till_cap)
		character.velocity += accel_speed * wish_dir

func _handle_ground_physics(delta: float) -> void:
	var current_speed_in_wish_dir = character.velocity.dot(wish_dir)
	var add_till_cap = get_move_speed() - current_speed_in_wish_dir
	if add_till_cap > 0:
		var accel_speed = ground_accel * delta * get_move_speed()
		accel_speed = min(accel_speed, add_till_cap)
		character.velocity += accel_speed * wish_dir
	
	var control = max(character.velocity.length(), ground_friction)
	var drop = control * ground_friction * delta
	var new_speed = max(character.velocity.length() - drop, 0.0)
	if character.velocity.length() > 0:
		new_speed /= character.velocity.length()
	character.velocity *= new_speed

	
func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	wish_dir = character.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	
	if character.is_on_floor():
		if Input.is_action_just_pressed("ui_accept") or (auto_bhop and Input.is_action_pressed("ui_accept")):
			character.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	character.move_and_slide()
