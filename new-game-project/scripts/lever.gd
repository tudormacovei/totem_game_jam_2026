extends Area3D

@export var is_left_zone_positive := true
@export var is_useless_scenario := false
@onready var mesh: MeshInstance3D = $LeverMesh/box_22

var normal_mat: Material
var outline_mat: Material

# Rotation configuration
var ROT_MAX_Z := 15.0
var ROT_SPEED := 0.2
var zone_to_positivity_dict := {} # Populated at runtime based on is_left_zone_positive

# State variables
var rotating := false
var last_mouse_pos := Vector2()
var is_mouse_over := false
var is_complete := false

# Zones: 1 - Left, 2 - Center, 3 - Right

func _ready() -> void:
	normal_mat = mesh.get_active_material(0)
	outline_mat = preload("res://materials/outline.tres")

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	zone_to_positivity_dict[1] = is_left_zone_positive
	zone_to_positivity_dict[3] = not is_left_zone_positive

func _input(event: InputEvent) -> void:
	if is_complete:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_mouse_over:
				rotating = true
				last_mouse_pos = event.position
			else:
				if rotating:
					_try_complete_lever()
				
				rotating = false
				if not is_mouse_over:
					mesh.set_surface_override_material(0, normal_mat)
				
	if event is InputEventMouseMotion and rotating:
		var delta = event.position - last_mouse_pos
		_rotate_lever(delta.x)
		last_mouse_pos = event.position

func _on_mouse_entered() -> void:
	if is_complete:
		return

	is_mouse_over = true
	mesh.set_surface_override_material(0, outline_mat)

func _on_mouse_exited() -> void:
	if is_complete:
		return

	is_mouse_over = false
	if not rotating:
		mesh.set_surface_override_material(0, normal_mat)

func _rotate_lever(delta_z: float):
	var rot = rotation_degrees
	rot.z += delta_z * ROT_SPEED
	rot.z = clamp(rot.z, -ROT_MAX_Z, ROT_MAX_Z)
	rotation_degrees = rot

func _try_complete_lever():
	var zone = _get_current_zone()

	if zone == 1 or zone == 3:
		GameManager.on_lever_completed(zone_to_positivity_dict[zone])
		is_complete = true
		mesh.set_surface_override_material(0, normal_mat)
		# TODO: Snap to the end of the zone
		return

	print("Lever not completed, still in zone 2")
					

# Zones are calculated by dividing area (-rot_delta_max, rot_delta_max) into 3 equally sized zones
# Zone 1 - Left, Zone 2 - Center, Zone 3 - Right
func _get_current_zone() -> int:
	var z = rotation_degrees.z
	var z1 = - ROT_MAX_Z / 3.0
	var z2 = ROT_MAX_Z / 3.0

	if z < z1:
		return 1
	elif z < z2:
		return 2
	else:
		return 3
