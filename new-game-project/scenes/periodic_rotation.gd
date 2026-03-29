extends Node3D

@export var rotation_magnitude: float = 1.0
@export var rotation_speed: float = 1.0

@export var on_x: bool = false
@export var on_y: bool = false
@export var on_z: bool = false


var starting_rotation: Vector3
var elapsed_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	starting_rotation = global_rotation
	elapsed_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var rotation_val = sin(elapsed_time * rotation_speed) * deg_to_rad(rotation_magnitude)
	if on_x:
		global_rotation.x = starting_rotation.x + rotation_val
	if on_y:
		global_rotation.y = starting_rotation.y + rotation_val
	if on_z:
		global_rotation.z = starting_rotation.z + rotation_val

	elapsed_time += delta
