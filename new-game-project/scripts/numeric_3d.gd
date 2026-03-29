class_name numeric_3d extends Node3D

@export var number_scenes: Array[PackedScene]
@export var tracking_likes: bool = false
@export var k_scene: PackedScene

var _target_number: float = 0.0
var _current_number: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_number(int(_current_number))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tracking_likes:
		_target_number = GameManager.get_current_like_amount()
	else:
		_target_number = GameManager.get_current_comment_amount()
	_update_number()


# place meshes along the X axis
func show_number(num: int) -> void:
	# delete any children, if they exist
	for child in get_children():
		child.free()

	var num_str = str(num)
	if num > 100000:
		num_str = str(num / 1000) # thousands

	var pos := Vector3(0, 0, 0)

	for c in num_str:
		if int(c) not in range(10):
			continue
		var num_obj = number_scenes[int(c)].instantiate() as Node3D
		add_child(num_obj)
		num_obj.position = pos
		var scale_factor = 0.6
		num_obj.scale = Vector3(scale_factor, scale_factor, scale_factor)
		pos.x += 1.5 * scale_factor
	
	if num > 100000:
		var k_obj = k_scene.instantiate() as Node3D
		add_child(k_obj)
		pos.x += 0.1
		var scale_factor = 0.6
		k_obj.scale = Vector3(scale_factor, scale_factor, scale_factor)
		k_obj.position = pos

func _update_number() -> void:
	if abs(_current_number - _target_number) > 0.5:
		_current_number = lerp(_current_number, 0.1 * _target_number, get_process_delta_time())
		show_number(int(_current_number))
