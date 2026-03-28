class_name LeverScore extends Node3D

@export var background_left: PackedScene
@export var background_right: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var bg_left_obj = background_left.instantiate() as Node3D
	var bg_right_obj = background_right.instantiate() as Node3D
	
	add_child(bg_left_obj)
	add_child(bg_right_obj)
	bg_left_obj.global_position = Vector3(-1.6, 0.3, 0.0)
	bg_right_obj.global_position = Vector3(1.6, 0.3, 0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
