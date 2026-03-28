extends Node

@export var diorama_scene: PackedScene

enum ScrollState {
	SCROLLING,
	PAUSED
}

var scene_locations : Array[Vector3]

var _state : ScrollState
var _time_in_current_state : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_state = ScrollState.PAUSED
	_time_in_current_state = 0.0
	
	# compute the scene locations
	var diorama_scene_height = 13.1
	var active_dioramas := 5
	
	for i in range(active_dioramas):
		var position := Vector3(0, diorama_scene_height * (i - active_dioramas / 2), 0)
		scene_locations.append(position)
		
		var diorama_node := diorama_scene.instantiate() as Node3D
		add_child(diorama_node)
		diorama_node.global_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_in_current_state += delta
	#if _state == ScrollState.SCROLLING and _time_in_current_state > SCROLL_TIME:
		#
	#if _state == ScrollState.PAUSED and _time_in_current_state > PAUSED_TIME:
		
func _animate_scroll() -> void:
	pass
