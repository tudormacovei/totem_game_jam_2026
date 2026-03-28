class_name numeric_3d extends Node3D

@export var number_scenes: Array[PackedScene]
@export var tracking_likes: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_numbers()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if tracking_likes:
		show_number(GameManager.get_current_like_amount())
	else:
		show_number(GameManager.get_current_comment_amount())


func test_numbers() -> void:
	show_number(1234567890)

# place meshes along the X axis
func show_number(num: int) -> void:
	# delete any children, if they exist
	for child in get_children():
		child.free()

	var num_str = str(num)
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
