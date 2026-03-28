extends Node

@export var diorama_scenes: Array[PackedScene]
@export var animation_profile: Curve

@export var SCROLL_TIME = 1.5
@export var PAUSE_TIME = 3.0

enum ScrollState{
	PAUSED,
	SCROLLING
}

var _state : ScrollState
var _time_in_current_state : float

var diorama_scene_height = 12.6

var loaded_dioramas: Array[Node3D] = []
var next_diorama_index : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_diorama()
	_add_diorama()
	_state = ScrollState.PAUSED
	_time_in_current_state = 0.0
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_in_current_state += delta
	if _state == ScrollState.SCROLLING and _time_in_current_state > SCROLL_TIME:
		_animate_scroll(delta)
		_state = ScrollState.PAUSED
		_time_in_current_state = _time_in_current_state - SCROLL_TIME

	elif _state == ScrollState.PAUSED and _time_in_current_state > PAUSE_TIME:
		_state = ScrollState.SCROLLING
		_time_in_current_state = _time_in_current_state - PAUSE_TIME
		_add_diorama()

	if _state == ScrollState.SCROLLING:
		_animate_scroll(delta)


## Add a diorama to the stack, at the top.
## Does not modify the position of current objects in the stack
func _add_diorama() -> void:
	if next_diorama_index >= diorama_scenes.size():
		return

	var diorama_node = diorama_scenes[next_diorama_index].instantiate()
	add_child(diorama_node)
	var top_position = Vector3(0, -diorama_scene_height, 0)
	if loaded_dioramas.size() > 0:
		top_position = loaded_dioramas[loaded_dioramas.size() - 1].global_position
	
	diorama_node.global_position = top_position + Vector3(0, diorama_scene_height, 0)
	loaded_dioramas.append(diorama_node)
	next_diorama_index += 1

# frees diorama objects below camera view
func _cleanup_diorama_stack() -> void:
	var i = 0
	while i < loaded_dioramas.size():
		var obj = loaded_dioramas[i]
		if obj.global_position.y < -20.0:
			obj.queue_free()
			loaded_dioramas.remove_at(i)
		else:
			i += 1

func _get_offset(x) -> float:
	return animation_profile.sample(x) * diorama_scene_height

func _animate_scroll(delta_time) -> void:
	var x = clamp(_time_in_current_state / SCROLL_TIME, 0.0, 1.0)
	var x_prev = clamp((_time_in_current_state - delta_time) / SCROLL_TIME, 0.0, 1.0)
	var delta_offset = _get_offset(x) - _get_offset(x_prev)
	
	for diorama_obj in loaded_dioramas:
		diorama_obj.global_position.y -= delta_offset
	
	_cleanup_diorama_stack()
