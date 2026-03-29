extends NinePatchRect
class_name Comment

const PADDING = Vector2(200, 0)
const RESTRICTED_POS_START = 280 * SCREEN_SIZE_SCALE # TODO These restrictions are not implemented right now. Comments only spawn on left side
const RESTRICTED_POS_END = 1100
const COMMENT_LIFETIME = 5

const SCREEN_SIZE_SCALE = 14

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var comment_text: String = ""

func _ready() -> void:
	if comment_text != "":
		call_deferred("init_comment")

func init_comment() -> void:
	await get_tree().process_frame
	label.text = comment_text
	await get_tree().process_frame
	print("Comment size: ", label.size)
	self.size = label.size + PADDING
	position = _get_new_position()
	if not is_on_left_side(): # This check works but the flip of the sprite doesn't for some reason. FOR NOW: only spawn on left side
		pivot_offset = size / 2
		scale.x = -1
		label.scale.x = -1

	self.show()
	anim_player.play("popup")
	print("Comment position: ", position)

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = COMMENT_LIFETIME
	timer.one_shot = true
	timer.connect("timeout", Callable(self , "_on_timer_timeout"))
	timer.start()

func init_comment_text(text: String) -> void:
	comment_text = text
	call_deferred("init_comment")

func _is_valid_position(pos: Vector2) -> bool:
	var end_x = pos.x + self.size.x / 2 # pivot is at center
	return end_x <= RESTRICTED_POS_START
	
func _get_new_position() -> Vector2:
	var pos = _get_random_position()
	while not _is_valid_position(pos):
		pos = _get_random_position()
	return pos

func _get_random_position() -> Vector2:
	randomize()
	var parent_size = get_tree().root.get_visible_rect().size * SCREEN_SIZE_SCALE
	var my_size = self.size

	var x = randf_range(0, parent_size.x - my_size.x)
	var y = randf_range(0, parent_size.y - my_size.y)
	return Vector2(x, y)

func is_on_left_side() -> bool:
	var screen_width = get_tree().root.get_visible_rect().size.x * SCREEN_SIZE_SCALE
	return position.x < screen_width * 0.5

func _on_timer_timeout() -> void:
	anim_player.play_backwards("popup")
	await get_tree().create_timer(10.0).timeout
	queue_free()
