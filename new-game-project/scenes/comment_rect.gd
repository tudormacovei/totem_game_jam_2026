extends NinePatchRect
class_name Comment

const PADDING = Vector2(100, 0)
const RESTRICTED_POS_START = 280
const RESTRICTED_POS_END = RESTRICTED_POS_START + 550

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var comment_text: String = ""

# TODO dissapear after time

func _ready() -> void:
	if comment_text != "":
		call_deferred("init_comment")

func init_comment() -> void:
	await get_tree().process_frame
	print("INIT comment", comment_text)
	label.text = comment_text
	await get_tree().process_frame
	self.size = label.size + PADDING
	position = _get_new_position()
	self.show()
	anim_player.play("popup")

func init_comment_text(text: String) -> void:
	comment_text = text
	call_deferred("init_comment")

func _is_valid_position(pos: Vector2) -> bool:
	var end_x = pos.x + self.size.x / 2 # pivot is at center
	return end_x <= RESTRICTED_POS_START or end_x >= RESTRICTED_POS_END
	
func _get_new_position() -> Vector2:
	var pos = _get_random_position()
	while not _is_valid_position(pos):
		pos = _get_random_position()
	return pos

func _get_random_position() -> Vector2:
	randomize()
	var parent_size = get_viewport_rect().size
	var my_size = self.size

	var x = randf_range(0, parent_size.x - my_size.x)
	var y = randf_range(0, parent_size.y - my_size.y)
	return Vector2(x, y)
