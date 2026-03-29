extends Camera3D

var original_pos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
		if event is InputEventMouseMotion:
			var pos_pixel = event.position
			var pos_normalized = event.position / get_viewport().get_visible_rect().size
			pos_normalized -= Vector2(0.5, 0.5)
			var pos_offset = Vector3(pos_normalized.x, pos_normalized.y, 0)
			
			global_position = original_pos + pos_offset
