class_name Lever extends Area3D

@export var is_left_zone_positive := true
@export var intensity: GameManager.Intensity = GameManager.Intensity.LOW

@onready var snap_to_completion_curve: Curve = preload("res://resources/curves/anim_lever_snap_curve.tres")
@onready var mesh: MeshInstance3D = $LeverMesh/lever_2

var normal_mat: Material
var outline_mat: Material = preload("res://materials/outline.tres")

# Configuration variables
var ROT_MAX_Z := 19.0
var ROT_SPEED := 0.08
var SNAP_ANIM_DURATION := 0.4
var SCALE_TWEEN_SPEED := 12.0
var SCALE_MAX_SIZE = 1.05
var SCALE_PRESSED_SIZE = 1.025
var ATTENTION_PULSE_SIZE = 1.025
var ATTENTION_PULSE_DURATION = 0.25
var TIME_UNTIL_ATTENTION_PULSE = 10
var zone_to_positivity_dict := {} # Populated at runtime based on is_left_zone_positive

# Tutorial variables
var time_no_choice = 0
var has_clicked_once := false

# State variables
var rotating := false
var last_mouse_pos := Vector2()
var is_mouse_over := false
var is_complete := false

# Snap animation variables
var start_z = null
var end_z = null
var t := 0.0
var is_playing_snap_anim := false
var has_focus: bool = false
var attention_pulse_tween: Tween

# Zones are calculated by dividing area (-rot_delta_max, rot_delta_max) into 3 equally sized zones
# Zones: 1 - Left, 2 - Center, 3 - Right

func _ready() -> void:
	normal_mat = mesh.get_active_material(0)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	zone_to_positivity_dict[1] = is_left_zone_positive
	zone_to_positivity_dict[3] = not is_left_zone_positive

func _process(delta: float) -> void:
	_set_scale(delta)

	if GameManager.in_tutorial and not has_clicked_once:
		time_no_choice += delta

		if time_no_choice > TIME_UNTIL_ATTENTION_PULSE and not is_mouse_over and not rotating:
			_start_attention_pulse()
		else:
			_stop_attention_pulse()
	else:
		_stop_attention_pulse()

	if is_playing_snap_anim:
		t += delta / SNAP_ANIM_DURATION
		if t >= 1.0:
			t = 1.0
			is_playing_snap_anim = false
		else:
			var z = snap_to_completion_curve.sample(t)
			z = clamp(z, -ROT_MAX_Z, ROT_MAX_Z)
			rotation_degrees.z = start_z + (end_z - start_z) * z
			return

func _input(event: InputEvent) -> void:
	if not is_active():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and is_mouse_over:
				has_clicked_once = true
				_stop_attention_pulse()
				rotating = true
				last_mouse_pos = event.position
				GameManager.update_intensity(intensity)
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
	is_mouse_over = true
	_stop_attention_pulse()
	#mesh.set_surface_override_material(0, outline_mat)

func _on_mouse_exited() -> void:
	is_mouse_over = false
	if not rotating:
		mesh.set_surface_override_material(0, normal_mat)

func _set_scale(delta: float) -> void:
	if not has_focus:
		return

	if _is_attention_pulsing() and not is_mouse_over and not rotating:
		return

	var target_scale := Vector3.ONE

	if is_mouse_over:
		target_scale = Vector3.ONE * SCALE_MAX_SIZE

	if rotating:
		target_scale = Vector3.ONE * SCALE_PRESSED_SIZE

	var weight = 1.0 - exp(-SCALE_TWEEN_SPEED * delta)
	scale = scale.lerp(target_scale, weight)

func _start_attention_pulse() -> void:
	if not has_focus or is_complete or _is_attention_pulsing():
		return

	attention_pulse_tween = create_tween()
	attention_pulse_tween.set_loops()
	attention_pulse_tween.set_trans(Tween.TRANS_SINE)
	attention_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	attention_pulse_tween.tween_property(self, "scale", Vector3.ONE * ATTENTION_PULSE_SIZE, ATTENTION_PULSE_DURATION)
	attention_pulse_tween.tween_property(self, "scale", Vector3.ONE, ATTENTION_PULSE_DURATION)

func _stop_attention_pulse() -> void:
	if attention_pulse_tween != null:
		attention_pulse_tween.kill()
		attention_pulse_tween = null

func _is_attention_pulsing() -> bool:
	return attention_pulse_tween != null

func _rotate_lever(delta_z: float):
	var rot = rotation_degrees
	rot.z += delta_z * ROT_SPEED
	rot.z = clamp(rot.z, -ROT_MAX_Z, ROT_MAX_Z)
	rotation_degrees = rot

func _try_complete_lever():
	var zone = _get_current_zone()

	start_snap_to_completion(zone)

	if zone == 1 or zone == 3:
		GameManager.play_sound(zone == 1)
		GameManager.on_lever_completed(zone_to_positivity_dict[zone], self)
		is_complete = true
		mesh.set_surface_override_material(0, normal_mat)
		return

	print("Lever not completed, still in zone 2")
					
func start_snap_to_completion(zone: int) -> void:
	start_z = rotation_degrees.z
	end_z = _get_zone_snap_point_z(zone)
	t = 0.0
	is_playing_snap_anim = true

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

func _get_zone_snap_point_z(zone: int) -> float:
	if zone == 1:
		return -ROT_MAX_Z
	elif zone == 3:
		return ROT_MAX_Z
	return 0.0

func is_active() -> bool:
	if is_complete or not has_focus:
		return false
	return true

func focus_gained() -> void:
	has_focus = true

func _on_focus_loss() -> void:
	if is_complete:
		return
	
	_stop_attention_pulse()
	is_complete = true
	has_focus = false
	_on_mouse_exited() # force mouse exit event
