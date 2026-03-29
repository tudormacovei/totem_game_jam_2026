extends NinePatchRect

const PADDING = Vector2(100, 0)

@onready var label: Label = $Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	self.size = label.size + PADDING

	anim_player.play("popup")
