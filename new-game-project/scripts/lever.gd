extends Area3D

@onready var mesh: MeshInstance3D = $LeverMesh/box_22

var normal_mat: Material
var outline_mat: Material

# Rotation configuration
var rot_max_z := 15.0
var rot_speed := 0.2

# State variables
var rotating := false
var last_mouse_pos := Vector2()
var is_mouse_over := false


func _ready() -> void:
	normal_mat = mesh.get_active_material(0)
	outline_mat = preload("res://materials/outline.tres")

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_mouse_over:
				rotating = true
				last_mouse_pos = event.position
			else:
				if rotating:
					print("Lever is in zone ", _get_current_zone())
				
				rotating = false
				if not is_mouse_over:
					mesh.set_surface_override_material(0, normal_mat)
				
	if event is InputEventMouseMotion and rotating:
		var delta = event.position - last_mouse_pos
		_rotate_lever(delta.x)
		last_mouse_pos = event.position

func _on_mouse_entered() -> void:
	is_mouse_over = true
	mesh.set_surface_override_material(0, outline_mat)

func _on_mouse_exited() -> void:
	is_mouse_over = false
	if not rotating:
		mesh.set_surface_override_material(0, normal_mat)

func _rotate_lever(delta_z: float):
	var rot = rotation_degrees
	rot.z += delta_z * rot_speed
	rot.z = clamp(rot.z, -rot_max_z, rot_max_z)
	rotation_degrees = rot

# Zones are calculated by dividing area (-rot_delta_max, rot_delta_max) into 3 equally sized zones
# Zone 1 - Left, Zone 2 - Center, Zone 3 - Right
func _get_current_zone() -> int:
	var z = rotation_degrees.z
	var z1 = - rot_max_z / 3.0
	var z2 = rot_max_z / 3.0

	if z < z1:
		return 1
	elif z < z2:
		return 2
	else:
		return 3