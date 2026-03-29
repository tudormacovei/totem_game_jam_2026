extends Node3D

@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect


func _ready() -> void:
	fade_rect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
